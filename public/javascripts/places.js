function toggle_drawer(id,e) {
  var a = $('#'+id + " .place_long");
  var b = "";
  if(a.is(':visible')) {
    a.href="#/places?expand="+id;
    b = "#/places?";
  } else {
    a.href="#/places?";
    b = "#/places?expand="+id;
  }
  a.toggle('blind');
  window.location=b;
}

function update_nowIndicator() {
  a=document.getElementById('nowIndicatorStyle')
  nowOffset = ((new Date().getHours() * 60 + new Date().getMinutes()) * 100 / (24*60));
  $(a).html( '.place .schedule .nowindicator { left: '+nowOffset.toString()+'%;}' );
}

function update_operatingStatus() {
  a=$('.place');
  a.removeClass('open');
  a.addClass('closed');
  a.each(function(){
    $('.timeblock',$(this)).each(function(){
      if( nowOffset>=parseFloat(this.style.left) && 
          nowOffset<=(parseFloat(this.style.left) + parseFloat(this.style.width)) ) {
        b=$(this).closest('.place');
        if(b.hasClass('closed')) { b.removeClass('closed'); };
        b.addClass('open');
      }
    });
  });
}

function update_nextTime() {
  /*  Not (really) possible by just parsing the the timeblocks
    *  Better off just grabbing some JSON with the proper strings
    */
}





// Rewrite to use # tag in URL and run function on location change
function handleTagClick(selectedTag,clickEvent) {
  if(document.selectedTags == null){document.selectedTags = new Array();}

  if( document.lockedTags.match(clickEvent.target.id.sub(/^selected_tag_/,'')) &&
      clickEvent.target == document.getElementById("selectedTags").childElements()[0] ) {
    // Trying to deselect primary tag. Oh no!
    // Just clear all selected tags instead
    document.selectedTags = new Array();

    while( (elements = document.getElementById("selectedTags").childElements()).length > 1 ) {
      unselected_id = elements[1].id.sub(/^selected_/,'');
      elements[1].parentNode.removeChild(elements[1]);
      document.getElementById(unselected_id).style['display'] = '';
    }

  } else if( clickEvent.target.parentNode == document.getElementById("selectedTags") ) {
    // Remove a tag from the current list of filters
    // and display the "unselected" version
    unselected_id = clickEvent.target.id.sub(/^selected_/,'');
    clickEvent.target.parentNode.removeChild(clickEvent.target);
    document.getElementById(unselected_id).style['display'] = '';

    var newSelectedTags;
    if(newSelectedTags == null){newSelectedTags = new Array();}

    for( var i=0; i<document.selectedTags.length; i++ ) {
      var tag = document.selectedTags[i];
      if(tag != selectedTag) {
        newSelectedTags[newSelectedTags.length] = tag;
      }
    }
    document.selectedTags = newSelectedTags;
    newSelectedTags = null;

  } else {
    // Add a tag to the current list of filters
    // and hide the "unselected" version
    selectedElement = clickEvent.target.cloneNode(true);
    selectedElement.className = "selectedTag";
    selectedElement.id = "selected_" + selectedElement.id;
    document.getElementById("selectedTags").appendChild(selectedElement);

    clickEvent.target.style['display'] = 'none';

    document.selectedTags[document.selectedTags.length] = selectedTag;
  }

  var elements = document.getElementById("places_table").getElementsByTagName('div');
  // Hide/Display appropriate places
  for( var i=0; i<elements.length; i++ ) {
    var e = elements[i];
    if(e && e.className && e.className.match(/placeRow/)){
      var matchedAll = true;
      document.selectedTags.forEach(function(tag){
        matchedAll = matchedAll && e.className.match(tag);
      });
      if( matchedAll ) {
        e.style['display'] = '';
      } else {
        e.style['display'] = 'none';
      }
    }
  }
}
