function loadConversation(card) {
  if($(card).find('.badge-dot').is(":visible")) {
    $(card).find('.badge-dot').hide();

    var total = $('#total-unread-label').data('total');
    var contact_total = $(card).data('unread');

    if((total - contact_total) > 0) {
      $('#total-unread-label').html((total - contact_total) + ' unread');
      $('#total-unread-label').data('total', total - contact_total);
    } else {
      $('#total-unread-label').hide();
    }
  }

  $('#thread-body').hide();
  $('#loading-thread').show();
  $('#thread-body').html('');
}
