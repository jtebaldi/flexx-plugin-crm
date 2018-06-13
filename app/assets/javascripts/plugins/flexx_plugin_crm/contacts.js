function submitNewContactForm() {
  $('#new-contact-add').toggleClass('disabled');
  $('#new-contact-cancel').toggleClass('disabled');
  $('#new-contact-spinner').toggleClass('invisible');

  $('#new-contact-form').submit();
}

function updateSalesStage(stage) {
  $('#update-sales-stage-field').val(stage);

  $('#update-sales-stage-form').submit();
}

function addNewContactTask() {
  $('#new-contact-task-add').toggleClass('disabled');
  $('#new-contact-task-cancel').toggleClass('disabled');
  $('#new-contact-task-spinner').toggleClass('invisible');

  $('#new-contact-task-form').submit();
}

function clearNewContactTaskForm() {
  $('#new-contact-task-form')[0].reset();

  $('#new-contact-task-add').toggleClass('disabled');
  $('#new-contact-task-cancel').toggleClass('disabled');
  $('#new-contact-task-spinner').toggleClass('invisible');

  $('#new-contact-task-panel').fadeOut();
}

app.ready(function() {
  var sample_tags = ['Event', 'Facebook', 'Cancelled'];

  var sample_tags = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    local: sample_tags
  });

  $('#tags-typeahead').length > 0 && $('#tags-typeahead').tagsinput({
    typeaheadjs: {
      name: 'contact_tags',
      source: sample_tags
    }
  });
})
