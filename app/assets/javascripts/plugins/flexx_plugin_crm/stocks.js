function saveSnippetStock() {
  if ($('#snippet-stock-form')[0].checkValidity()) {
    $('#snippet-stock-save').toggleClass('disabled');
    $('#snippet-stock-cancel').toggleClass('disabled');
    $('#snippet-stock-spinner').toggleClass('invisible');
  }

  $('#snippet-stock-form').submit();
}

function closeSnippetStock(button) {
  $('#snippet-stock-form')[0].reset();
  quickview.close($(button).closest('.quickview'));
}

app.ready(function() {
  var observer = new MutationObserver(function () {
    ClassicEditor
    .create(document.querySelector('.editor'))
    .catch(function(error){
      console.error(error);
    });
  });

  observer.observe(document.getElementById('qv-stock'), { childList: true });
});
