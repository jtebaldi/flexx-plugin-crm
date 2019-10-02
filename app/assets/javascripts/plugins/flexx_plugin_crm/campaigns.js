function submitNewCampaignForm() {
  $('#new-campaign-add').toggleClass('disabled');
  $('#new-campaign-cancel').toggleClass('disabled');
  $('#new-campaign-spinner').toggleClass('invisible');

  $('#new-campaign-form').submit();
}

function addNewCampaignStep() {
  $('#new-campaign-step-form').submit();
}

function clearNewCampaignStepForm() {
  $('#new-campaign-step-form')[0].reset();

  $("#new-campaign-step-add-button").toggleClass('btn-primary btn-warning disabled');
  $("#new-campaign-step-add-button > i").toggleClass('ti-plus ti-more');

  $('#new-campaign-step-panel').fadeOut();
}


$('document').ready(function(){

  $('#new-campaign-step-schedule-button').length &&
    $('#new-campaign-step-schedule-button').on('click', function(e) {
      $('#new-campaign-step-immediate-button').removeClass('btn-info');
      $('#new-campaign-step-schedule-button').addClass('btn-info');
      $('#new-campaign-step-timming-panel').show();

      e.preventDefault();
    });

  $('#new-campaign-step-immediate-button').length &&
    $('#new-campaign-step-immediate-button').on('click', function(e) {
      $('#new-campaign-step-immediate-button').addClass('btn-info');
      $('#new-campaign-step-schedule-button').removeClass('btn-info');
      $('#new-campaign-step-timming-panel').hide();

      $("#new-campaign-step-form input[name='campaign_step[due_on_value]']").val('');
      $("#new-campaign-step-form select[name='campaign_step[due_on_unit]']").prop('selectedIndex', 0);

      e.preventDefault();
    });

  $('#new-campaign-step-form').validator().on('submit', function (e) {
    if (e.isDefaultPrevented()) {
      e.preventDefault();
      e.stopPropagation();
    }
    else {
      $('#new-campaign-step-add').toggleClass('disabled');
      $('#new-campaign-step-cancel').toggleClass('disabled');
      $('#new-campaign-step-spinner').toggleClass('invisible');
    }
  });

  $('#new-campaign-step-add-button').on('click', function(e) {
    $('#new-campaign-step-panel').toggle();
    $('#new-campaign-step-add-button').toggleClass('btn-primary btn-warning disabled');
    $("#new-campaign-step-add-button > i").toggleClass('ti-plus ti-more');
  });

  $(document).on('rendered.bs.select', '#update-campaign-associated-forms', function(e) {
    $('#update-campaign-form').trigger('submit.rails');
  });
});
