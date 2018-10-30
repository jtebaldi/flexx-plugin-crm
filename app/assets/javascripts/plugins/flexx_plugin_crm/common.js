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
  $('#task-send-text-spinner').toggleClass('invisible');
  try {
    ckeditor.updateSourceElement();
  } catch(err) {
  } finally {
    $('#task-send-message-form').submit();
  }
}

function saveNote(e, taskId) {
  e.preventDefault();
  var text = $('#update-task-form textarea').val();
  $('#notes-content').load('/admin/next/tasks/' + taskId + '/create_note', { text: text });
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
