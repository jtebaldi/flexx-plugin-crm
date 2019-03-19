// Enables/Disables input fields associated with switch
function toggleDisableInput(checkboxElem) {
  if (checkboxElem.checked) {
    $(checkboxElem).parent().parent().find('.avatar').addClass("active");
    $('.' + checkboxElem.id).find('div.form-group, div.form-group .form-control button').removeClass("disabled");
    $('.' + checkboxElem.id).find('input.form-control').prop('required', true);
  } else {
    $(checkboxElem).parent().parent().find('.avatar').removeClass("active");
    $('.' + checkboxElem.id).find('div.form-group, div.form-group .form-control button').addClass("disabled");
    $('.' + checkboxElem.id).find('input').prop('required', false);
  }
}

var taglist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '/admin/next/list_tags'
});

app.ready(function() {
  taglist.initialize();

  $('#typeahed-tags').tagsinput({
    typeaheadjs: {
      name: 'taglist',
      source: taglist.ttAdapter(),
      displayKey: 'name',
      valueKey: 'name'
    }
  });

  // Intially disables all input fields if switch is off
  $('.setting-switch:checkbox:not(:checked)').each(function () {
    $('.' + this.id).find('div.form-group').addClass("disabled");
  });

  // Show "save changes" bar on input change
  $('form :input').on('change input', function() {
    $(this).closest("form").find('.save-changes-bar').removeClass('hidden');
  });
});
