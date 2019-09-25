function submitNewCampaignForm() {
  $('#new-campaign-add').toggleClass('disabled');
  $('#new-campaign-cancel').toggleClass('disabled');
  $('#new-campaign-spinner').toggleClass('invisible');

  $('#new-campaign-form').submit();
}
