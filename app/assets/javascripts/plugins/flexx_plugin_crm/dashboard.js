console.log('dashboard');
$(function(){
  $('[data-from-form]').click(function(){
    var $modal = $('#contact_form_modal');
    $body = $modal.find('.modal-body');
    $body.html('<div class="spinner-circle-shadow mx-auto"></div>');
    $.get('/admin/next/dashboard/from_form', { contact_id: this.dataset.fromForm }, function(resp){
      $body.html(resp);
    });
    $modal.modal('show');
  });
});
