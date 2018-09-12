function submitNewContactForm() {
  if ($('#new-contact-form')[0].checkValidity()) {
    $('#new-contact-add').toggleClass('disabled');
    $('#new-contact-cancel').toggleClass('disabled');
    $('#new-contact-spinner').toggleClass('invisible');
  }

  $('#new-contact-form').submit();
}

function cancelNewContactForm(button) {
  $('#new-contact-form')[0].reset();
  $('#typeahed-tags').tagsinput('removeAll');
  $('#new-contact-form [data-provide~="selectpicker"]').selectpicker('val', '');
  quickview.close($(button).closest('.quickview'));
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

function addNewPhoneRow() {
  var newrow = $('#phone-row-template').clone();
  $(newrow).find('select').selectpicker({
    iconBase: '',
    tickIcon: 'ti-check',
    style: 'btn-light'
  });
  $(newrow).toggleClass('hidden').appendTo('#phone-rows');
}

var taglist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '/admin/next/list_tags'
});

app.ready(function() {
  taglist.initialize();

  $('#typeahed-tags').tagsinput({
    typeaheadjs: {
      name: 'taglist',
      source: taglist.ttAdapter(),
      displayKey: 'name',
      valueKey: 'name'
    }
  });
})
