$(() => {
  const tabNav = (e) => {
    let tab = e.target.attributes.href.value.match(/[a-z]+$/);
    let url = '/admin/next/settings';
    if (tab && tab[0] !== 'settings') {
      tab =  tab[0];
      url += '/' + tab;
    } else tab = '';

    history.pushState({ tab: tab }, document.title, url);
  }

  $('.nav-pills .nav-link').click(tabNav);

  $('#link-to-profile').click((e) => {
    e.preventDefault();
    $('a[href="#tab_profile"]').trigger('click');
  });

  window.onpopstate = (e) => {
      $(`a[href="#tab_${window.location.pathname.match(/[a-z]+$/)}"]`).tab('show');
  }

  $('#settings-form, #user_form, #password-form').on('submit', (e) => {
    e.preventDefault();
    $.ajax({
      url: $(e.target).attr('action'),
      method: 'patch',
      data: $(e.target).serialize(),
    });
  });

  $('#user_avatar').change((ev) => {
    if (ev.target.files && ev.target.files[0]) {
      var reader = new FileReader();
      reader.onload = (e) => {
        $('[data-user-avatar]').css('background-image', `url(${e.target.result})`).hide().html('').fadeIn(650);
        var formdata = new FormData();
        formdata.append('avatar', ev.target.files[0]);
        $.ajax({
          url: '/admin/next/settings/avatar_update',
          method: 'patch',
          processData: false,
          contentType: false,
          data: formdata,
        });
      }
      reader.readAsDataURL(ev.target.files[0]);
    }
  });

  $('#delete-avatar').click(() => {
    var $avatars = $('[data-user-avatar]');
    var $avatar = $avatars.last();
    if ($avatar.html() !== $avatar.data('user-avatar') && confirm('Are you sure?')) {
      $avatars.css('background-image', '').html($avatar.data('user-avatar'));
      $('#user_avatar').val(null);
      $.ajax({
        url: '/admin/next/settings/avatar_delete',
        method: 'delete',
      });
    }
  });

  // $.fn.size = () => { return this.length }

  // var form = $('#user_form .btn_change_photo');
  // form.click(function(){
  //   $.fn.upload_filemanager({
  //     formats: 'image',
  //     selected: function (file) {
  //       form.find('#user_meta_avatar').val(file.url);
  //       form.find('img.img-thumbnail').attr('src', file.url);
  //     }
  //   });
  //   return false;
  // });
});