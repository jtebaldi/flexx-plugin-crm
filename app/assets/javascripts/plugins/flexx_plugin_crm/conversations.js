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
  $('#conversations-text-button').toggleClass('hidden');
  $('#conversations-text-spinner').toggleClass('hidden');
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

  // -------------------------- START: Make thread fullscreen

  const fullscreentarget = $('#thread-body')[0]; // Get DOM element from jQuery collection
  var fullscreentrigger = "#expand_thread";

  $(document).on('click', fullscreentrigger, function(){
    if (screenfull.enabled) {
      $(fullscreentrigger).addClass('is-fullscreen')
      screenfull.toggle(fullscreentarget);
    }
  });

  document.addEventListener(screenfull.raw.fullscreenchange, function() {
    if (screenfull.isFullscreen) {
      $(fullscreentrigger).each(function(){
        $(this).addClass('is-fullscreen')
      });
    }
    else {
      $(fullscreentrigger).each(function(){
        $(this).removeClass('is-fullscreen')
      });
    }
  });

  // -------------------------- END: Make thread fullscreen

  // $('.scrollable').perfectScrollbar({
  //   wheelPropagation: false,
  //   wheelSpeed: .5,
  // });
  // $('#conversations-thread-panel').scrollToEnd();

  $('#filter-unanswered').click((e) => {
    var $contacts = $('#inbox-list > a');
    if ($(e.target).attr('aria-pressed') === 'true') {
      $contacts.removeClass('hidden');
    } else {
      $contacts.not('[data-unanswered="true"]').addClass('hidden');
    }

    var $notHidden = $contacts.not('.hidden');
    if ($notHidden.length) {
      $notHidden.first().trigger('click');
    } else {
      $('#thread-body').html('');
    }
  })

  $('[data-sort-conversation]').click((e) => {
    var $this = $(e.currentTarget);
    $this.closest('.btn-group').find('.filter-option').html($this.data('sortConversation'));
    $('[data-sort-conversation').removeClass('selected');
    $this.addClass('selected');
  });
});
