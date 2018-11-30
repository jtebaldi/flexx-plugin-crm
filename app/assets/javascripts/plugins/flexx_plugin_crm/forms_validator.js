$(function(){
  $('form[data-provide="custom-validation"]').validator({
    custom: {
      'contact-email': function($elm) {
        setTimeout(() => {
          
          var emailInUse = 'The email is already in use.';
          var $feedback = $elm.siblings('div.invalid-feedback');
          if ($feedback.html().length && $feedback.find('li').html() !== emailInUse) return;
          $.get('/admin/next/contacts/email_validate', {
            contact_id: $elm.data('contact-email'),
            contact: { email: $elm.val() }
          }, function(data) {
            switch (data) {
              case false:
                $elm.addClass('is-invalid');
                $feedback.html('<ul class="list-unstyled"><li>' + emailInUse + '</li></ul>');
                break;
              case true:
                $elm.removeClass('is-invalid');
                $feedback.html('');
                break;
              default:
                if (confirm('Contact with email ' + $elm.val() + ' is achived. Would you like to resote it.')){

                }
                break;
            }         
          });
        }, 0);
      }
    }
  });

  // var emailInUse = 'The email is already in use.';
  // var $validator = $('form[data-provide="jquery-validation"]').validate({
  //   errorClass: 'invalid',
  //   validClass: 'valid',
  //   errorElement: 'div',
  //   ignore: '.no-vlaidate',
  //   // highlight: function(elm, errCls, vldCls) {
  //   //   $(elm).addClass(errCls).removeClass(vldCls)
  //   // },
  //   // unhighlight: function(elm, errCls, vldCls) {
  //   //   $(elm).addClass(vldCls).removeClass(errCls)
  //   // },
  //   rules: {
  //     'user[email]': {
  //       email: true,
  //       required: true,
  //       remote: '/admin/next/settings/email_validate'
  //     },
  //     'user[username]': {
  //       required: true,
  //       remote: '/admin/next/settings/username_validate'
  //     },
  //     'contact[email]': {
  //       email: true,
  //       required: true,
  //       remote: {
  //         url: '/admin/next/contacts/email_validate',
  //         data: { contact_id: function() {
  //           var form = document.getElementById('tab_contact_details');
  //           return form && form.action.match(/\d+$/)[0];
  //         } },
  //         success: function(data) {
  //           switch (data) {
  //             case true:
  //               $validator.hideErrors();
  //               break;
  //             case false:
  //               $validator.showErrors({ 'contact[email]': emailInUse });
  //               break;
  //             default:
  //               break;
  //           }
  //           return data;
  //         }
  //       }
  //     }
  //   },
  //   messages: {
  //     'user[email]': { remote: 'The email is already in use.' },
  //     'user[username]': { remote: 'The username is already in use.' },
  //     'contact[email]': { remote: 'The email is already in use.' }
  //   }
  // });
});