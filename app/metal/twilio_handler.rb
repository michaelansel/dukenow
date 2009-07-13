# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
require 'sinatra/base'
require 'twilio'

Twilio::AuthToken = ENV['TWILIO_AUTH_TOKEN'] unless defined? Twilio::AuthToken

class TwilioHandler < Sinatra::Base

  before do
    not_found unless request.path_info.match(/^\/twilio/)

    @r = Twilio::Response.new

    if  request.post? and
        not Twilio::Auth.valid?(request.url(), request.POST(), env['HTTP_X_TWILIO_SIGNATURE'])
      @r.say("Unable to authenticate request. Please try again.")
      halt(401, @r.to_xml)
    end

    puts "Session: #{session.inspect}"
    puts "Params: #{params.inspect}"

    body { @r }
    content_type :xml
  end

  helpers do
    def short_time_string(time)
      if time.min == 0 # time has no minutes
        time.strftime('%I%p').sub(/^0+/,'')
      else # time has minutes
        time.strftime('%I:%M%p').sub(/^0+/,'')
      end
    end
  end

  def self.any(*args,&block)
    get(*args,&block)
    post(*args,&block)
    put(*args,&block)
    delete(*args,&block)
  end

  def self.post(*args, &block)
    super(*args,&block) # real post
    get(*args,&block)
  end
  def self.real_post(path, opts={}, &bk)
    route 'POST',   path, opts, &bk
  end



  post /^\/twilio\/?$/ do
    # Reset menu options session variable
    session[:menu] = {}

    # Find all open places
    @places = Place.find(:all, :limit => 8).select{|p| p.open?}

    #@r.say "There are #{@places.length} open now."
    uri = URI.parse(request.url); uri.path = '/twilio/details'; uri.query = nil
    @r.gather(:action => uri.to_s) do |g|
      g.say "Press 1 at any time to search by name."
      session[:menu]["1"] = :search

      @places.each_index do |i|
        p = @places[i]
        g.say "#{i+2}: #{p.name} is open until #{short_time_string(p.currentSchedule[1])}"

        #session[:place_ids][i+2] = p.id
        session[:menu][(i+2).to_s] = p.id
      end
    end
    @r.hangup


    nil
  end

  post /^\/twilio\/details$/ do
    menu_uri = URI.parse(request.url); menu_uri.path = '/twilio'; menu_uri.query = nil

    if session[:menu].nil?
      @r.say "I'm sorry, there was an internal error. Please call back and try again. Goodbye!"
      @r.hangup
      puts "session[:menu].nil? == true"
      debugger

      return nil
    end

    if not session[:menu].has_key?( params[:Digits] )
      @r.say "Sorry, I'm afraid I don't understand that."
      @r.say "Please try again."
      @r.redirect menu_uri.to_s

      return nil
    end

    if session[:menu][ params[:Digits].to_s ] == :search
      menu_uri.path = '/twilio/search'
      @r.redirect(menu_uri.to_s, :method => 'GET')

      return nil
    end

    place = Place.find( session[:menu][ params[:Digits].to_s ] )
    if place.nil? # Okay, we are stupid. We just found it a few seconds ago!
      @r.say "I'm sorry; it seems I've misplaced that location"
      @r.say "How about we pretend that didn't happen, and you can look up something else?"
      @r.redirect menu_uri.to_s
      return nil
    end

    @r.say "#{place.name} is open until #{short_time_string(place.currentSchedule[1])}"

    #also = ""
    #place.schedule(Time.now,Time.now.midnight + 24.hours).each do |open,close|
      #@r.say "#{place.name} is " + also + "open today from #{short_time_string(open)} to #{short_time_string(close)}."
      #also = "also "
    #end

    campus = place.tags.collect{|tag| tag.name.match(/campus/i) ? tag.name.sub(/campus/,'') : nil }.first
    @r.say "It is located on #{campus} " unless campus.nil?

    @r.say "I hope that was helpful. Enjoy your meal!"
    @r.hangup

    nil
  end












  get /^\/twilio\/search$/ do
    @r.gather(:action => request.url, :method => 'POST', :numDigits => 3) do |g|
      g.say "Please enter the first three letters of the place you are looking for"# or press star to search by location."
    end
    @r.say "I'm sorry, I didn't detect you entering 3 letters or pressing star. Please try again"
    @r.redirect(request.url, :method => 'GET')

    nil
  end






  Keypad = ["", "",                ["A","B","C"],  ["D","E","F"],
                ["G","H","I"],     ["J","K","L"],  ["M","N","O"],
                ["P","Q","R","S"], ["T","U","V"],  ["W","X","Y","Z"]];

  real_post /^\/twilio\/search$/ do
    if params[:Digits].nil?
      @r.say "Invalid request"
      @r.redirect request.url, :method => 'GET'
    end

    if params[:Digits].match(/[0\*#]/)
      @r.say "One or more invalid keys were pressed. Please try again."
      @r.redirect request.url, :method => 'GET'
    end



    digits = params[:Digits].split(/\s*/)
    conditions = [""]
    Keypad[digits[0].to_i].each do |a|
      Keypad[digits[1].to_i].each do |b|
        Keypad[digits[2].to_i].each do |c|
          conditions[0] += " UPPER(name) LIKE ? OR UPPER(name) LIKE ? OR "
          conditions << "#{a+b+c}%"
          conditions << "% #{a+b+c}%"
        end
      end
    end
    conditions[0].gsub!(/ OR $/,'')
    puts "Conditions: #{conditions.inspect}"
    @places = Place.find(:all, :conditions => conditions);




    uri = URI.parse(request.url); uri.path = '/twilio/details'; uri.query = nil
    session[:menu] = {}
    if @places.size == 0
      @r.say "Sorry, I couldn't find any results. Please try again."
      uri.path = '/twilio'
      @r.redirect uri.to_s, :method => "POST"

    elsif @places.size == 1
      @r.say "Match found! Loading details for #{@places[0].name}"
      session[:menu]["1"] = @places[0].id
      uri.query = "Digits=1"
      @r.redirect uri.to_s, :method => "POST"

    else
      @r.say "Multiple results found. Please select one"
      g = @r.gather(:action => uri.to_s, :method => 'POST', :numDigits => 1)

      @places = @places.sort{|a,b| a.name <=> b.name }
      @places.each_index do |i|
        p = @places[i]
        g.say "#{i+1}: #{p.name}"
        session[:menu][(i+1).to_s] = p.id
      end

      @r.say "I'm sorry, I didn't detect a selection. Please try again."
      @r.children << g.dup
      @r.say "I'm sorry, I still couldn't detect a selection. Please call back and try again."
      @r.hangup
      #me = uri.dup; me.query = "Digits=#{params[:Digits]}"
      #@r.redirect me.to_s
    end

    nil
  end

end
