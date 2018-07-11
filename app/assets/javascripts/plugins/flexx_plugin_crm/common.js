function deferTask(taskId, currentValue) {
  $('#defer-task-id-field').val(taskId);
  $('#defer-current-due-date-field').val(currentValue);
  $('#modal-defer-task').modal('show');
}

function sendConfirmation(taskId) {
  $('#send-confirmation-task-id-field').val(taskId);
  $('#modal-send-confirmation').modal('show');
}
