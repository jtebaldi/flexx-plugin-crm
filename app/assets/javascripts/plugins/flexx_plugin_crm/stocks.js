function saveTextStock() {
  if ($('#text-stock-form')[0].checkValidity()) {
    $('#text-stock-save').toggleClass('disabled');
    $('#text-stock-cancel').toggleClass('disabled');
    $('#text-stock-spinner').toggleClass('invisible');
  }

  $('#text-stock-form').submit();
}

function closeTextStock(button) {
  $('#text-stock-form')[0].reset();
  quickview.close($(button).closest('.quickview'));
}

app.ready(function() {
  ClassicEditor
    .create(document.querySelector('.editor'))
    .catch(function(error){
      console.error(error);
    });
});
