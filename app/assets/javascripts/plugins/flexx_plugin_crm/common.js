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
  $('#task-send-message-form').submit();
}

function closeTaskView(button) {
  quickview.close($(button).closest('.quickview'));
}
