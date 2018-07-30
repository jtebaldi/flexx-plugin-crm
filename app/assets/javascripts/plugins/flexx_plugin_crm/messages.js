var contactlist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('first_name'),
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

  $('#typeahed-recipients').tagsinput(
    {
      typeaheadjs: [
        {},
        {
          name: 'taglist',
          source: taglist.ttAdapter(),
          displayKey: 'name',
          valueKey: 'name'
        },
        {
          name: 'contactlist',
          source: contactlist.ttAdapter(),
          displayKey: 'first_name',
          valueKey: 'email'
        }
      ]
  });

  ClassicEditor
    .create(document.querySelector('.editor'))
    .catch(function(error){
      console.error(error);
    });
})