function submitNewContactForm() {
  $('#new-contact-add').toggleClass('disabled');
  $('#new-contact-cancel').toggleClass('disabled');
  $('#new-contact-spinner').toggleClass('invisible');

  $('#new-contact-form').submit();
}

app.ready(function() {
  var sample_tags = ['Event', 'Facebook', 'Cancelled'];

  var sample_tags = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    local: sample_tags
  });

  $('#tags-typeahead').tagsinput({
    typeaheadjs: {
      name: 'contact_tags',
      source: sample_tags
    }
  });
})