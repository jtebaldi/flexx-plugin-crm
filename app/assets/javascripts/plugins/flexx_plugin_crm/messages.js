var contactlist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '/admin/next/list_contacts'
});

var taglist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '/admin/next/list_tags'
});

app.ready(function() {
  taglist.initialize();
  contactlist.initialize();

  var tm = $('#recipients').tagsManager();

  $('#recipients').on('tm:refresh', function(){
    var pos = $('.tt-input').position();
    $('.tt-hint').css({
      'position':'absolute',
      'top': pos.top,
      'left': pos.left
    })
  });

  $('#recipients').typeahead({
    highlight: true,
    hint: true
  },
  {
    name: 'taglist',
    displayKey: 'name',
    source: taglist.ttAdapter(),
    templates: {
      header: '<h3>Tags</h3>'
    }
  },
  {
    name: 'contactlist',
    displayKey: 'name',
    source: contactlist.ttAdapter(),
    templates: {
      header: '<h3>Contacts</h3>'
    }
  }
  ).on('typeahead:selected', function(e,d){ // Push result to tag and clear value
    tm.tagsManager('pushTag', d.value); // Use Tag Manager to push tag in
    $('#recipients').typeahead('val', ''); // Clear input box after pushed tag
  });


  ClassicEditor
    .create(document.querySelector('.editor'))
    .catch(function(error){
      console.error(error);
    });
})