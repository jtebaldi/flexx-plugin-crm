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

function addNewTask() {
  $('#new-task-add').toggleClass('disabled');
  $('#new-task-cancel').toggleClass('disabled');
  $('#new-task-spinner').toggleClass('invisible');

  $('#new-task-form').submit();
}

function cancelNewTaskForm(button) {
  $('#new-task-form')[0].reset();
  quickview.close($(button).closest('.quickview'));
}

function closeTaskView(button) {
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
    valueKey: 'value',
    source: contactlist
  });

  var clearContactId = true;

  $('#contacts-field').bind('typeahead:change', function() {
    if(clearContactId) {
      $('#new-task-contact-id').val('');
    } else {
      clearContactId = true;
    }
  });

  $('#contacts-field').bind('typeahead:selected', function(e, option) {
    $('#new-task-contact-id').val(option.value);
    clearContactId = false;
  });
});
