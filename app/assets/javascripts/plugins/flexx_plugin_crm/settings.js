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

  $('#settings-form, #user-form, #password-form').on('submit', (e) => {
    e.preventDefault();
    $.ajax({
      url: $(e.target).attr('action'),
      method: 'patch',
      data: $(e.target).serialize(),
    });
  });
});