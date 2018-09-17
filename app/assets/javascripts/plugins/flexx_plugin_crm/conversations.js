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
  $("#conversations-send-message-form :input").prop("readonly", true);
}

app.ready(function() {
  $('#conversations-send-message-form').on('submit', submitConversationsSendMessageForm);
});
