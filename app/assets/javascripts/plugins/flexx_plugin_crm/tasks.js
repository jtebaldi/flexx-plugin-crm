var contactlist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: { url: '/admin/next/contacts/with_email', cache: false }
});

function updateTask(button, isDone) {
  if(isDone) {
    $('#task-status').val('done');
  }

  $('#update-task-form').submit();

  quickview.close($(button).closest('.quickview'));
}

function addNewTask() {
  $('#new-task-add').toggleClass('disabled');
  $('#new-task-cancel').toggleClass('disabled');
  $('#new-task-spinner').toggleClass('invisible');

  $('#new-task-form').submit();
}

function cancelNewTaskForm(button) {
  $('#new-task-form')[0].reset();
  quickview.close($(button).closest('.quickview'));
}

function findMatch(haystack, arr) {
  return arr.some(function (v) {
    return haystack.indexOf(v) >= 0;
  });
}

function checkedStaff() {
  $(".task-card").not('.completed').hide();

  setTimeout(function(){
    if ($("input[name='staff']:checked").length == $("input[name='staff']").length) {
      $("input[name='staffAll']").prop('checked', true);
    } else if ($("input[name='staff']:not(:checked)").length > 0) {
      $("input[name='staffAll']").prop('checked', false);
    }

    var checked = [];
    $("input[name='staff']:checked").each(function () {
      checked.push($(this).val());
    });

    $(".task-card").not('.completed').each(function(obj){
      var owner_ids = [];
      owner_ids = $(this).attr('data-staff');

      if ((findMatch(owner_ids, checked)) || (owner_ids.length === 0)) {
        $(this).show();
      }
    });
  }, 50);
}

app.ready(function() {
  contactlist.initialize();

  $('#contacts-field').typeahead({
    hint: true,
    highlight: true
  },
  {
    name: 'contactlist',
    displayKey: 'name',
    valueKey: 'value',
    source: contactlist
  });

  var clearContactId = true;

  $('#contacts-field').bind('typeahead:change', function() {
    if(clearContactId) {
      $('#new-task-contact-id').val('');
    } else {
      clearContactId = true;
    }
  });

  $('#contacts-field').bind('typeahead:selected', function(e, option) {
    $('#new-task-contact-id').val(option.value);
    clearContactId = false;
  });

  checkedStaff();

  $('nav#taskNav > a').click(function(event){
    var active_tab = $(this).attr('href');

    if (active_tab == "#tab-completed") {
      $('#pendingStaff').hide();
    } else {
      $('#pendingStaff').show();
    }

  });

  $('[data-assign="staff"]').click((e) => {
    $(e.target.dataset.target).modal({ backdrop: false });
  });

  $('#modal-assign-staff [data-dismiss="modal"]').click((e) => {
    e.stopPropagation();
    e.preventDefault();
    $(e.target).closest('.modal').modal('hide');
  });

  $('#modal-assign-staff a.media').click((e) => {
    setTimeout(()=> {
      var $form = $(e.target).closest('form');
      var $assignTo = $form.find('.avatar-list');
      var staff = '';
      $form.find('[name="task[owner_ids][]"]:checked').each((i, elm) => {
        var av = $(elm).closest('a').find('.avatar').html();
        staff += `<span class="avatar bg-dark">${av}</span>`
      });
      $assignTo.html(staff);
    });
  });

  observeTaskPanelForCKEditor();
});
