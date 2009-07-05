# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'
require 'spec/capabilities'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end


ConstraintDebugging = false
def add_scheduling_spec_helpers(place)
  place.instance_eval do

    def operating_times
      regular_operating_times + special_operating_times
    end

    def regular_operating_times
      @regular_operating_times ||= []
    end
    def special_operating_times
      @special_operating_times ||= []
    end
    def constraints
      @constraints ||= []
    end
    def times
      @times ||= []
    end


    def add_constraint(&block)
      puts "Adding constraint: #{block.to_s.sub(/^[^\@]*\@/,'')[0..-2]}" if ConstraintDebugging
      self.constraints << block
    end

    # Test +time+ against all constraints for +place+
    def acceptable_time(time)
      if ConstraintDebugging
        puts "Testing Time: #{time.inspect}"
      end

      matched_all = true
      self.constraints.each do |c|
        matched = c.call(time)

        if ConstraintDebugging
          if matched
            puts "++ Time accepted by constraint"
          else
            puts "-- Time rejected by constraint"
          end
          puts "     Constraint: #{c.to_s.sub(/^[^\@]*\@/,'')[0..-2]}"
        end

        matched_all &= matched
      end

      if ConstraintDebugging
        if matched_all
          puts "++ Time Accepted"
        else
          puts "-- Time Rejected"
        end
        puts ""
      end

      matched_all
    end

    def add_times(new_times = [])
      new_times.each do |t|
        unless t[:start] and t[:length]
          raise ArgumentError, "Must specify a valid start offset and length"
        end
      end
      times.concat(new_times)
    end

    def build(at = Time.now)
      if ConstraintDebugging
        puts "Rebuilding #{self}"
        puts "Constraints:"
          constraints.each do |c|
            puts "  #{c.to_s.sub(/^[^\@]*\@/,'')[0..-2]}"
          end
        puts "Times:"
          times.each do |t|
            puts "  #{t.inspect}"
          end
      end

      regular_operating_times.clear
      special_operating_times.clear
      operating_times.clear

      self.times.each do |t|
        t=t.dup
        if acceptable_time(t)
          t[:override]   ||= false
          t[:startDate]  ||= at.to_date - 2
          t[:endDate]    ||= at.to_date + 2
          t[:daysOfWeek] ||= OperatingTime::ALL_DAYS
          t[:place_id]   ||= self.id
          ot = OperatingTime.new
          t.each{|k,v| ot.send(k.to_s+'=',v)}

          puts "Added time: #{ot.inspect}" if ConstraintDebugging

          if t[:override]
            self.special_operating_times << ot
          else
            self.regular_operating_times << ot
          end

        end
      end

      if ConstraintDebugging
        puts "Regular Times: #{self.regular_operating_times.inspect}"
        puts "Special Times: #{self.special_operating_times.inspect}"
      end

      self
    end
    alias :build! :build
    alias :rebuild :build
    alias :rebuild! :build

  end
end # add_scheduling_spec_helpers(place)
