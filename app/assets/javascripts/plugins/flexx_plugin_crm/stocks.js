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

function saveRichTextStock() {
  if ($('#rich-text-stock-form')[0].checkValidity()) {
    $('#rich-text-stock-save').toggleClass('disabled');
    $('#rich-text-stock-cancel').toggleClass('disabled');
    $('#rich-text-stock-spinner').toggleClass('invisible');
  }

  window.ckeditor.updateSourceElement();

  $('#rich-text-stock-form').submit();
}

function closeRichTextStock(button) {
  $('#rich-text-stock-form')[0].reset();
  quickview.close($(button).closest('.quickview'));
}

function insertDynamicField(textareaInput, mergeField) {
    var cursorPos = $(textareaInput).prop('selectionStart');
    var v = $(textareaInput).val();
    var textBefore = v.substring(0,  cursorPos);
    var textAfter  = v.substring(cursorPos, v.length);

    $(textareaInput).val(textBefore + mergeField + textAfter);
}

app.ready(function() {
  var observer = new MutationObserver(function () {
    ClassicEditor
    .create(document.querySelector('.editor'), window.dynamic_fields)
    .then(function(editor){
      window.ckeditor = editor;
    })
    .catch(function(error){
      console.error(error);
    });
  });

  observer.observe(document.getElementById('qv-stock'), { childList: true });
});
