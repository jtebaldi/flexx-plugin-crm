var contactlist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: { url: '/admin/next/list_contacts_with_mobile', cache: false }
});

function loadConversation(card) {
  if($(card).data('unread') > 0) {
    var total = $('#total-unread-label').data('total');
    var contact_total = $(card).data('unread');

    if((total - contact_total) > 0) {
      $('#total-unread-label').html((total - contact_total) + ' unread');
      $('#total-unread-label').data('total', total - contact_total);
    } else {
      $('#total-unread-label').hide();
    }

    $(card).find('.badge-dot').hide();
    $(card).data('unread', 0);
  }

  $('#thread-body').hide();
  $('#loading-thread').show();
  $('#thread-body').html('');
}

function submitConversationsSendMessageForm(e) {
  e.preventDefault();

  if($('#conversations-text-message').val() == ''){
    return false;
  }

  $('#conversations-text-message').toggleClass('disabled');
  $('#conversations-text-button').toggleClass('disabled');
  $('#conversations-text-spinner').toggleClass('invisible');
  $('#conversations-send-message-form :input').prop('readonly', true);
}

function submitConversationsSendNewMessageForm(e) {
  e.preventDefault();

  if($('#conversations-text-new-message').val() == ''){
    return false;
  }

  $('#conversations-text-new-message').toggleClass('disabled');
  $('#conversations-text-new-send-button').toggleClass('disabled');
  $('#conversations-text-new-cancel-button').toggleClass('disabled');
  $('#conversations-text-new-spinner').toggleClass('invisible');
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
      $('#new-conversation-contact-id').val('');
    } else {
      clearContactId = true;
    }
  });

  $('#contacts-field').bind('typeahead:selected', function(e, option) {
    $('#new-conversation-contact-id').val(option.value);
    clearContactId = false;
  });

  $('#conversations-send-message-form').on('submit', submitConversationsSendMessageForm);
  $('#conversations-send-new-message-form').on('submit', submitConversationsSendNewMessageForm);

  // $('.scrollable').perfectScrollbar({
  //   wheelPropagation: false,
  //   wheelSpeed: .5,
  // });
  // $('#conversations-thread-panel').scrollToEnd();
});
