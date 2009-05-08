function handleTagClick(selectedTag,clickEvent) {
  if(clickEvent.shiftKey) {
    if(document.selectedTags == null){document.selectedTags = new Array();}
    document.selectedTags[document.selectedTags.length] = selectedTag;
  } else {
    document.selectedTags = new Array();
    document.selectedTags[0] = selectedTag;
  }
  elements = document.getElementsByTagName('div');
  for( i in elements ) {
    e = elements[i];
    if(e && e.className && e.className.match(/placeRow/)){
      matchedAll = true;
      document.selectedTags.forEach(function(selectedTag){
        if( matchedAll && e.className.match(selectedTag) ) {
          e.style['display'] = '';
        }else{
          e.style['display'] = 'none';
          matchedAll = false;
        }
      });
    }
  }
}
