  function submitNewContactForm() {
    // if ($('#new-contact-form')[0].checkValidity()) {
    // $('#new-contact-add').toggleClass('disabled');
    // $('#new-contact-cancel').toggleClass('disabled');
    // $('#new-contact-spinner').toggleClass('invisible');
    // }

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
  } else if (stage === 'delete') {
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
  } else {
    $('#update-sales-stage-field').val(stage);

    $('#update-sales-stage-form').submit();
  }
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

function submitConversationsSendMessageForm(e) {
  e.preventDefault();

  if($('#contact-conversations-text-message').val() == ''){
    return false;
  }

  $('#contact-conversations-text-message').toggleClass('disabled');
  $('#contact-conversations-text-button').toggleClass('hidden');
  $('#contact-conversations-text-spinner').toggleClass('hidden');
  $("#conversations-send-message-form :input").prop("readonly", true);
}

var taglist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '/admin/next/list_tags'
});

function newTouchpoint(e) {
  $('.touchpoint').addClass('disabled');

  var form = $('#new-contact-task-form');

  form.find('select[name="task[task_type]"]').val(e.data.type);
  form.find('input[name="task[title]"]').val(e.data.title);
  form.find('input[name="task[touchpoint]"]').val('true');

  form.submit();
}

function selectedContactsCount() {
  var checkedCount = $("input:checkbox.contact-checkbox:checked").length;
  return checkedCount;
}

function archiveContacts() {
  var totalChecked = selectedContactsCount();
  swal({
    title: 'Archive ' + totalChecked + ' contacts',
    text: 'This will permanently remove all pending tasks and hide these contacts from your view. Are you sure you want to archive?',
    type: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Yes, archive them!',
    cancelButtonText: 'Nevermind'
  }).then((result) => {
    if (result.value) {
      $('#mass-action-option').val('archive');
      $('#mass-action-form').submit();
    } else {
      return;
    }
  })
}

function archiveSingleContact(id) {
  swal({
    title: 'Archive contact',
    text: 'This will permanently remove all pending tasks and hide this contact from your view. Are you sure you want to archive?',
    type: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Yes, archive it!',
    cancelButtonText: 'Nevermind'
  }).then((result) => {
    if (result.value) {
      $('#mass-action-contact-id').val(id);
      $('#mass-action-option').val('archive');
      $('#mass-action-form').submit();
    } else {
      return;
    }
  })
}

function cancelBulkTagging() {
  $('.typeahead-tags').tagsinput('removeAll');
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

  $('.typeahead-tags').tagsinput({
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

  var utilsScriptPath = $('[data-utils-script]').data('utilsScript');
  var telInput = elm => {
    var t = window.intlTelInput(elm, { utilsScript: utilsScriptPath });
    // elm.addEventListener('countrychange', () => { return; });
    var $elm = $(elm);
    $elm.change(() => {
      var $feedback = $elm.closest('.form-group').find('.invalid-feedback');
      t.setNumber(elm.value)
      if (elm.value.length) {
        var action = $elm.closest('form').attr('action');
        action = action.match(/\d+/) ? action : action + '/new';
        $.get(action + '/phone_validate', { number: t.getNumber() }, (data) => {
          if (data.message) {
            $elm.addClass('is-invalid');
            $feedback.html(`<ul class="list-unstyled"><li>${data.message}</li></ul>`).show();
          } else {
            $elm.removeClass('is-invalid');
            $feedback.html('');
          }
        });
      } else {
        $elm.removeClass('is-invalid');
        $feedback.html('');
      }
    });
    return t;
  }

  var telInputs = [];
  $('form input[type="tel"]').each((i, input) => {
    telInputs.push(telInput(input));
  });

  $('[data-add="phone"]').click(e => {
    var $newrow = $('#phone-row-template').clone();
    $newrow.find('select').selectpicker({
      iconBase: '',
      tickIcon: 'ti-check',
      style: 'btn-light'
    });
    $newrow.toggleClass('hidden').appendTo('#phone-rows');
    telInputs.push(telInput($newrow.find('input[type="tel"]')[0]));
  });

  $('#tab_contact_details, #new-contact-form').validator().on('submit', (e) => {
    if (e.isDefaultPrevented()) {
    } else {
      var $feedback = $(e.target).find('.invalid-feedback > ul');
      if ($feedback.length) {
        e.preventDefault();
        var $input = $feedback.closest('.form-group').find('.form-control');
        $([document.documentElement, document.body]).animate({
          scrollTop: ($input.offset().top - 100)
        }, 200);
        $input.focus();
      } else {
        $('#new-contact-add').addClass('disabled');
        $('#new-contact-cancel').addClass('disabled');
        $('#new-contact-spinner').removeClass('invisible');
        telInputs.forEach((elm) => { elm.a.value = elm.getNumber() });
      }
    }
  });

  $('[data-contacts-filter]').click((e) => {
    $('#selected-filter').html(e.target.innerHTML);
    var $records = $('#contact-list').children('tr');
    if (e.target.dataset.contactsFilter === 'none') {
      $records.removeClass('hidden');
    } else {
      $records.not(`[data-sales-stage="${e.target.dataset.contactsFilter}"]`).addClass('hidden');
      $records.filter(`[data-sales-stage="${e.target.dataset.contactsFilter}"]`).removeClass('hidden');
    }
  });

  var $contacts = $('[data-name]');

  $('#contact-search').keyup((e) => {
    $contacts.each((i, elm) => {
      var r = new RegExp(e.target.value.toLowerCase());
      var $elm = $(elm);
      if (r.test($elm.data('name').toLowerCase())) {
        $elm.removeClass('hidden');
      } else {
        $elm.addClass('hidden');
      }
    });
  });

  // Intially hide mass action button group
  $('#mass_action_btns').hide();
  // Conditionally show/hide mass action button group if any contact is selected
  $('.contact-checkbox').change(function() {
    // Need to delay checkbox check to account for short lag after Select All is unchecked
    setTimeout(function() {
      if ($("input[type=checkbox].contact-checkbox").is(":checked")) {
        $('#mass_action_btns').show();
      } else {
        $('#mass_action_btns').hide();
      }
     }, 10);
  });

  $('#modal-bulk-tag').on('show.bs.modal', function () {
    var totalChecked = selectedContactsCount();
    document.getElementById("tag-contact-num").textContent = totalChecked;
  })
});
