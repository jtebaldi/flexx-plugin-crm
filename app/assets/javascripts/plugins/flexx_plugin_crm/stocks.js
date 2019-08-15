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

function validateStockLabel(e) {
  console.log(e.key)
  if (e.key != 'Shift' && e.key != 'Tab' && e.key.match(/[^a-z_\-]/gi))
    e.preventDefault();
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

  $('#qv-stock').on('qv.loaded', () => {
    $('#snippet-stock-form').validator({
      custom: {
        'snippet-code': ($elm) => {
          if (['contact_email', 'contact_first_name', 'contact_last_name'].includes($elm.val())) {
            return 'The code is reserver for system snippet.';
          }
        },
        'snippet-name': ($elm) => {
          if (['E-mail', 'First Name', 'Last Name'].includes($elm.val())) {
            return 'The name is reserved for system snippet.';
          }
        }
      }
    }).on('submit', (e) => {
      if (e.isDefaultPrevented()) {
        e.stopPropagation();
      } else {

      }
    });
  });
});
