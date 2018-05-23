function submitNewTaskRecipeForm() {
  $('#new-task-recipe-add').toggleClass('disabled');
  $('#new-task-recipe-cancel').toggleClass('disabled');
  $('#new-task-recipe-spinner').toggleClass('invisible');

  $('#new-task-recipe-form').submit();
}

$('document').ready(function(){
  $("#timing_detail").hide();
  var rad = document.recipeStep.timingOptions;
  $(rad).on('click change', function(e) {
    if (rad.value == 2) {
      $("#timing_detail").show();
    } else {
      $("#timing_detail").hide();
    }
  });

  var stepFormPlaceholder = $("#step_placeholder");
  var stepForm = $("#new_step_form");
  var addStepBtn = $("#btn_add_step");
  stepForm.hide();
  addStepBtn.addClass('btn-primary');
  $(addStepBtn).on('click', function(e) {
    stepFormPlaceholder.toggle();
    stepForm.toggle();
    addStepBtn.toggleClass('btn-primary btn-warning disabled');
    $("#btn_add_step > i").toggleClass('ti-plus ti-more');
  });
});
