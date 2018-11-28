$(function(){
  $('form[data-provide="validation"]').validate({
    errorClass: 'invalid',
    validClass: 'valid',
    errorElement: 'div',
    ignore: '.no-vlaidate',
    highlight: function(elm, errCls, vldCls) {
      $(elm).addClass(errCls).removeClass(vldCls)
    },
    unhightight: function(elm, errCls, vldCls) { $(elm).addClass(vldCls).removeClass(errCls) },
    rules: {
      'user[email]': {
        email: true,
        required: true,
        remote: '/admin/next/settings/email_validate'
      },
      'user[username]': {
        required: true,
        remote: '/admin/next/settings/username_validate'
      },
      'contact[email]': {
        email: true,
        required: true,
        remote: {
          url: '/admin/next/contacts/email_validate',
          data: { contact_id: function() {
            var form = document.getElementById('tab_contact_details');
            return form && form.action.match(/\d+$/)[0];
          } }
        }
      }
    },
    messages: {
      'user[email]': { remote: 'The email is already in use.' },
      'user[username]': { remote: 'The username is already in use.' },
      'contact[email]': { remote: 'The email is already in use.' }
    }
  });
});