function submitNewContactForm() {
  $('#new-contact-add').toggleClass('disabled');
  $('#new-contact-cancel').toggleClass('disabled');
  $('#new-contact-spinner').toggleClass('invisible');

  $('#new-contact-form').submit();
}
