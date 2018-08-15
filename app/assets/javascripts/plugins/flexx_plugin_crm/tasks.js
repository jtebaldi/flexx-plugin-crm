var contactlist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: { url: '/admin/next/list_contacts', cache: false }
});

function updateTask(button, isDone) {
  if(isDone) {
    $('#task-status').val('done');
  }

  $('#update-task-form').submit();

  quickview.close($(button).closest('.quickview'));
}

app.ready(function() {
  contactlist.initialize();

  $('#contacts-field').typeahead({
    hint: true,
    highlight: true
  },
  {
    name: 'contactlist',
    displayKey: 'name',
    source: contactlist
  });
});
