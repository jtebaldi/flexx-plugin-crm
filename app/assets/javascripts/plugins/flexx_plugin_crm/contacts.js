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
  if (stage === 'archived') {
    swal({
      title: 'Archive this contact',
      text: 'This will permanently remove all pending tasks and hide this contact from your view. Are you sure you want to archive?',
      type: 'warning',
      showCancelButton: true,
      confirmButtonText: 'Yes, archive it!',
      cancelButtonText: 'No, keep it'
    }).then((result) => {
      if (result.value) {
        $('#update-sales-stage-field').val(stage);
        $('#update-sales-stage-form').submit();
      } else {
        return;
      }
    })
  }

  if (stage === 'delete') {
    swal({
      title: 'Delete this contact',
      text: 'This will permanently remove all pending tasks, messages, notes, and completed contact forms for this contact. Are you sure you want to delete?',
      type: 'warning',
      showCancelButton: true,
      confirmButtonText: 'Yes, delete it!',
      cancelButtonText: 'No, keep it'
    }).then((result) => {
      if (result.value) {
        $('#update-sales-stage-field').val(stage);
        $('#update-sales-stage-form').submit();
      } else {
        return;
      }
    })
  }

//   if (stage === 'archived' && !confirm('Archiving a contact\
//  will permanently remove all pending tasks and hide this contact from your\
//  view. Are you sure you want to archive?') || stage == 'delete' &&
//   !confirm('Deleting a contact will permanently remove all pending tasks,\
//  messages, notes, and competed contact forms. Are you sure you want to delete?')) {
//     return;
//   }
  // $('#update-sales-stage-field').val(stage);

  // $('#update-sales-stage-form').submit();
}

function addNewContactTask() {
  $('#new-contact-task-add').toggleClass('disabled');
  $('#new-contact-task-cancel').toggleClass('disabled');
  $('#new-contact-task-spinner').toggleClass('invisible');

  $('#new-contact-task-form').submit();
}

function clearNewContactTaskForm() {
  $('#new-contact-task-form')[0].reset();

  $('#new-contact-task-add').removeClass('disabled');
  $('#new-contact-task-cancel').removeClass('disabled');
  $('#new-contact-task-spinner').removeClass('invisible');

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

function submitConversationsSendMessageForm(e) {
  e.preventDefault();

  if($('#contact-conversations-text-message').val() == ''){
    return false;
  }

  $('#contact-conversations-text-message').toggleClass('disabled');
  $('#contact-conversations-text-button').toggleClass('disabled');
  $('#contact-conversations-text-spinner').toggleClass('invisible');
  $("#conversations-send-message-form :input").prop("readonly", true);
}

var taglist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '/admin/next/list_tags'
});

function newTouchpoint(e) {
  var form = $('#new-contact-task-form');

  form.find('select[name="new_contact_task[task_type]"]').val(e.data.type);
  form.find('input[name="new_contact_task[title]"]').val(e.data.title);
  form.find('input[name="new_contact_task[touchpoint]"]').val('true');

  form.submit();
}

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

  $('#conversations-send-message-form').on('submit', submitConversationsSendMessageForm);

  $('#new-send-email-touchpoint').click({ type: 'email', title: 'Email' }, newTouchpoint);
  $('#new-message-touchpoint').click({ type: 'message', title: 'Text' }, newTouchpoint);
  $('#new-phone-call-touchpoint').click({ type: 'phone_call', title: 'Phone call' },newTouchpoint);
  $('#new-meeting-touchpoint').click({ type: 'meeting', title: 'Meeting' },newTouchpoint);
  $('#new-general-touchpoint').click({ type: 'general', title: 'General' },newTouchpoint);

  observeTaskPanelForCKEditor();

  $('.archived form input').attr('readonly', 'readonly');
  $('.archived form button').attr('disabled', 'disabled');
});
