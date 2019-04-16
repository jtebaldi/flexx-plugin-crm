var contactlist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: { url: contactlist_url, cache: false }
});

var taglist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: { url: '/admin/next/list_tags', cache: false }
});

function fillRecipientsField() {
  $('#recipientsHidden').val($('#recipients').tagsManager('customTagIds'));
}

function pushTag(name, value) {
  value = value || name;

  $('#recipients').tagsManager('pushTag', name, false, null, false, value);
}

function sendTestMessage() {
  if (!$('#test-email-contact-id').val()) {
    return false;
  }
  window.ckeditor.updateSourceElement();

  $.ajax({
    url: '/admin/next/messages/send_test_email',
    data: {
      contact_id: $('#test-email-contact-id').val(),
      to: $('#test_email_to').val(),
      subject: $('#email_subject').val(),
      message: $('#email_body').val()
    },
    type: 'POST'
  }).done(function() {
    $('#test_message_modal').modal('hide');
    swal({
      type: 'success',
      title: 'Test message sent!',
      showConfirmButton: false,
      timer: 1500
    })
  });
}

app.ready(function() {
  //Override the default confirm dialog by rails
  $.rails.allowAction = function(link){
    if (link.data("confirm") == undefined){
      return true;
    }
    $.rails.showConfirmationDialog(link);
    return false;
  }

  //User click confirm button
  $.rails.confirmed = function(link){
    link.data("confirm", null);
    link.trigger("click.rails");
  }

  //Display the confirmation dialog
  $.rails.showConfirmationDialog = function(link){
    var message = link.data("confirm");
    swal({
      title: message,
      type: 'warning',
      confirmButtonText: 'Sure',
      confirmButtonColor: '#2acbb3',
      showCancelButton: true
    }).then((result) => {
      if (result.value) {
        $.rails.confirmed(link);
      } else {
        return;
      }
    });
  };

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

  $('#test-email-contacts-field').typeahead({
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

  $('#test-email-contacts-field').bind('typeahead:change', function() {
    if(clearContactId) {
      $('#test-email-contact-id').val('');
    } else {
      clearContactId = true;
    }
  });

  $('#test-email-contacts-field').bind('typeahead:selected', function(e, option) {
    $('#test-email-contact-id').val(option.value);
    clearContactId = false;
  });

  /********************************************************
   *
   * IMPORTANT: tagsManager must be called AFTER typeahead
   *
  ********************************************************/
  var tm = $('#recipients').tagsManager({
    prefilled: ('prefilled_tags' in window) ? prefilled_tags : []
  });

  $('#recipients').on('tm:refresh', function(){
    var pos = $('.tt-input').position();
    $('.tt-hint').css({
      'position':'absolute',
      'top': pos.top,
      'left': pos.left
    })
  });

  var recipientIds = $('#recipientsHidden').length > 0 ? $('#recipientsHidden').val().split(',') : [];
  $.each(recipientIds, function(idx, elm){
    var $recipient = $('[data-id="' + elm + '"]');
    pushTag($recipient.data('tag'), $recipient.data('id'));
  });

  ClassicEditor
    .create(document.querySelector('.editor'), window.dynamic_fields)
    .then(function(editor){
      window.ckeditor = editor;
    })
    .catch(function(error){
      console.error(error);
    });
})
