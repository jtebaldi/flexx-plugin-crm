var contactlist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: { url: '/admin/next/list_contacts', cache: false }
});

var taglist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: { url: '/admin/next/list_tags', cache: false }
});

function fillRecipientsField() {
  $('#recipientsHidden').val($('#recipients').tagsManager('customTagIds'));
}

app.ready(function() {
  taglist.initialize();
  contactlist.initialize();

  $("#recipients").on('tm:pushed', function(e, tag) {
    $('#recipients').typeahead('val', '');
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
    tm.tagsManager('pushTag', d.name, false, null, false, d.value);

    $('#recipients').typeahead('val', '');
  });

  /********************************************************
   *
   * IMPORTANT: tagsManager must be called AFTER typeahead
   *
  ********************************************************/
  var tm = $('#recipients').tagsManager();

  $('#recipients').on('tm:refresh', function(){
    var pos = $('.tt-input').position();
    $('.tt-hint').css({
      'position':'absolute',
      'top': pos.top,
      'left': pos.left
    })
  });

  ClassicEditor
    .create(document.querySelector('.editor'))
    .catch(function(error){
      console.error(error);
    });
})
