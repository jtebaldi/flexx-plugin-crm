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
    var $records = $('#contact-list').children('div');
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

  $('[data-contact-avatar-id] > input').change((ev) => {
    if (ev.target.files && ev.target.files[0]) {
      var reader = new FileReader();
      reader.onload = (e) => {
        var $avatar = $(ev.target).closest('[data-contact-avatar-id]');
        $avatar.find('[data-contact-avatar]').css('background-image', `url(${e.target.result})`).hide().html('').fadeIn(650);
        var contactId = $avatar.data('contactAvatarId');
        if (!contactId) return;
        var formdata = new FormData();
        formdata.append('avatar', ev.target.files[0]);
        $.ajax({
          url: `/admin/next/contacts/${contactId}/avatar`,
          method: 'patch',
          processData: false,
          contentType: false,
          data: formdata,
        });
      }
      reader.readAsDataURL(ev.target.files[0]);
    }
  });

  $('[data-delete-contact-avatar]').click((e) => {
    e.preventDefault();
    var $avatars = $(e.target).closest('[data-contact-avatar-id]').find('[data-contact-avatar]');
    var $avatar = $avatars.last();
    if ($avatar.html() !== $avatar.data('contact-avatar') && confirm('Are you sure?')) {
      $avatars.css('background-image', '').html($avatar.data('contact-avatar'));
      var inputGroup = $('[data-contact-avatar-id]');
      inputGroup.find('input').val(null);
      var contactId = inputGroup.data('contactAvatarId');
      if (!contactId) return;
      $.ajax({
        url: `/admin/next/contacts/${contactId}/avatar`,
        method: 'delete',
      });
    }
  });
});
