function submitNewTaskRecipeForm() {
  $('#new-task-recipe-add').toggleClass('disabled');
  $('#new-task-recipe-cancel').toggleClass('disabled');
  $('#new-task-recipe-spinner').toggleClass('invisible');

  $('#new-task-recipe-form').submit();
}

function addNewRecipeDirection() {
  $('#new-recipe-direction-add').toggleClass('disabled');
  $('#new-recipe-direction-cancel').toggleClass('disabled');
  $('#new-recipe-direction-spinner').toggleClass('invisible');

  if($("#new-recipe-direction-form input[name='timingOptions']:checked").val() == 'immediate') {
    $("#new-recipe-direction-form input[name='new_task_recipe_direction[due_on_value]']").val('0');
  }

  $('#new-recipe-direction-form').trigger('submit.rails');
}

function clearNewRecipeDirectionForm() {
  $('#new-recipe-direction-form')[0].reset();

  $('#new-recipe-direction-add').toggleClass('disabled');
  $('#new-recipe-direction-cancel').toggleClass('disabled');
  $('#new-recipe-direction-spinner').toggleClass('invisible');
  $("#new-recipe-direction-add-button").toggleClass('btn-primary btn-warning disabled');
  $("#new-recipe-direction-add-button > i").toggleClass('ti-plus ti-more');

  $('#new-recipe-direction-panel').fadeOut();
}

$('document').ready(function(){

  $('#new-recipe-direction-schedule-button').length &&
    $('#new-recipe-direction-schedule-button').on('click', function(e) {
      $('#new-recipe-direction-immediate-button').removeClass('btn-info');
      $('#new-recipe-direction-schedule-button').addClass('btn-info');
      $('#new-recipe-direction-timming-panel').show();

      e.preventDefault();
    });

  $('#new-recipe-direction-immediate-button').length &&
    $('#new-recipe-direction-immediate-button').on('click', function(e) {
      $('#new-recipe-direction-immediate-button').addClass('btn-info');
      $('#new-recipe-direction-schedule-button').removeClass('btn-info');
      $('#new-recipe-direction-timming-panel').hide();

      e.preventDefault();
    });

  var stepFormPlaceholder = $("#step_placeholder");
  var stepForm = $("#new-recipe-direction-panel");
  var addStepBtn = $("#new-recipe-direction-add-button");
  stepForm.hide();
  addStepBtn.addClass('btn-primary');
  $(addStepBtn).on('click', function(e) {
    stepFormPlaceholder.toggle();
    stepForm.toggle();
    addStepBtn.toggleClass('btn-primary btn-warning disabled');
    $("#new-recipe-direction-add-button > i").toggleClass('ti-plus ti-more');
  });
});
