function deferTask(taskId, currentValue) {
  $('#defer-task-id-field').val(taskId);
  $('#defer-current-due-date-field').val(currentValue);
  $('#modal-defer-task').modal('show');
}

function sendConfirmation(taskId) {
  $('#send-confirmation-task-id-field').val(taskId);
  $('#modal-send-confirmation').modal('show');
}

function submitTaskSendMessageForm() {
  $('#task-send-text-message').toggleClass('disabled');
  $('#task-send-text-button').toggleClass('disabled');
  $('#task-send-text-spinner').toggleClass('invisible'); try { ckeditor.updateSourceElement(); } catch(err) { } finally { $('#task-send-message-form').submit();
  }
}

function updateNotesCounter(taskId, $notes) {
  var $task = $('[data-open-task="' + taskId + '"]');
  var $commentsCounter = $task.find('.fa.fa-comment.mr-1').parent();
  if ($commentsCounter.length) {
    if ($notes.length) {
      $commentsCounter.find('span').text($notes.length);
    } else {
      $commentsCounter.detach();
    }
  } else {
    $task.find('footer > div:first').prepend(
      '<span class="text-lighter hover-light mr-15"><i class="fa fa-comment mr-1"></i><span>' + $notes.length + '</span></span>'
    );
  }
}

function saveNote(e, taskId) {
  e.preventDefault();
  var text = $(e.target).closest('.publisher').find('textarea').val();
  if (text.length) {
    $('#notes-content').load(
      '/admin/next/tasks/' + taskId + '/create_note',
      { text: text },
      function() {
        var $notes = $('#notes-content .media');
        updateNotesCounter(taskId, $notes)
      }
    );
  }
}

function closeTaskView(button) {
  quickview.close($(button).closest('.quickview'));
}

function observeTaskPanelForCKEditor() {
  if (!document.querySelector('#qv_view_task')) {
    return;
  }
  var observer = new MutationObserver(function () {
    ClassicEditor
    .create(document.querySelector('.editor'), window.dynamic_fields)
    .then(function(editor){
      window.ckeditor = editor;
    })
    .catch(function(error){
      console.error(error);
    });
  });

  observer.observe(document.querySelector('#qv_view_task'), { childList: true });
}

$(function(){
  $(document).on('click', '#notes-content [data-delete-note]', function(e) {
    e.preventDefault();
    if (confirm('Are you sure?')){
      var $this = $(this);
      var taskId = $this.closest('[data-task]').data('task');
      var $tasksList = $this.closest('.media-list');
      $this.closest('.media').detach();
      updateNotesCounter(taskId, $tasksList.find('.media'));
      $.ajax({
        url: '/admin/next/tasks/delete_note',
        data: { note_id: this.dataset.deleteNote },
        type: 'DELETE'
      });
    }
  });

  $(document).on('click', '#notes-content [data-note]', function() {
    var $this = $(this);
    $this.addClass('d-none');
    $this.parent().find('div').removeClass('d-none').find('textarea').focus();
  });

  $(document).on('focusout', '#notes-content [data-note] + div > textarea', function() {
    var $this = $(this);
    $this.parent().addClass('d-none');
    var $note = $this.closest('.media').find('[data-note]');
    $.ajax({
      url: '/admin/next/tasks/update_note',
      data: { note_id: $note.data('note'), text: $this.val() },
      type: 'PATCH'
    })
    $note.text($this.val());
    $note.removeClass('d-none');
  });

  $('[data-from-form]').click(function(e){
    e.preventDefault();
    var $modal = $('#contact_form_modal');
    $body = $modal.find('.modal-body');
    $body.html('<div class="spinner-circle-shadow mx-auto"></div>');
    $.get('/admin/next/from_form', { form_id: this.dataset.fromForm }, function(resp){
      $body.html(resp);
    });
    $modal.modal('show');
  });

  $('[data-delete-form]').click(function(e) {
    e.preventDefault();
    if (confirm('Are you sure?')) {
      var $this = $(this);
      var formId = $this.data('deleteForm');
      $.ajax({
        url: '/admin/next/delete_form',
        data: { form_id: formId },
        type: 'DELETE'
      });
      $this.closest('tr').detach();
    }
  });

  $(document).on('click', '[data-dynamic-field]', (e) => {
    var $input = $(e.target).closest('form').find('#contact-conversations-text-message,\
     #task-send-text-message, #conversations-text-message');
    var pos = $input[0].selectionStart;
    var text = $input.val();
    $input.val(`${text.substr(0, pos)}{{${e.target.dataset.dynamicField}}}${text.substr(pos, text.length)}`);
  });

  $(document).on('submit', '#defer-task-form', (e) => {
    e.preventDefault();
  });
});