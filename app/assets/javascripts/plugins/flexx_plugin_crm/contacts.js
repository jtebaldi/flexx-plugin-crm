  function submitNewContactForm() {
    // if ($('#new-contact-form')[0].checkValidity()) {
    // $('#new-contact-add').toggleClass('disabled');
    // $('#new-contact-cancel').toggleClass('disabled');
    // $('#new-contact-spinner').toggleClass('invisible');
    // }

    $('#new-contact-form').submit();
  }

function cancelNewContactForm(button) {
  $('#new-contact-form')[0].reset();
  $('#typeahed-tags').tagsinput('removeAll');
  $('#new-contact-form [data-provide~="selectpicker"]').selectpicker('val', '');
  quickview.close($(button).closest('.quickview'));
}

function updateSalesStage(stage) {
  if (stage === 'archived') {
    swal({
      title: 'Archive this contact',
      text: 'This will permanently remove all pending tasks and hide this contact from your view. Are you sure you want to archive?',
      type: 'warning',
      showCancelButton: true,
      confirmButtonText: 'Yes, archive it!',
      cancelButtonText: 'No, keep it'
    }).then((result) => {
      if (result.value) {
        $('#update-sales-stage-field').val(stage);
        $('#update-sales-stage-form').submit();
      } else {
        return;
      }
    })
  } else if (stage === 'delete') {
    swal({
      title: 'Delete this contact',
      text: 'This will permanently remove all pending tasks, messages, notes, and completed contact forms for this contact. Are you sure you want to delete?',
      type: 'warning',
      showCancelButton: true,
      confirmButtonText: 'Yes, delete it!',
      cancelButtonText: 'No, keep it'
    }).then((result) => {
      if (result.value) {
        $('#update-sales-stage-field').val(stage);
        $('#update-sales-stage-form').submit();
      } else {
        return;
      }
    })
  } else {
    $('#update-sales-stage-field').val(stage);

    $('#update-sales-stage-form').submit();
  }
}

function addNewContactTask() {
  $('#new-contact-task-add').toggleClass('disabled');
  $('#new-contact-task-cancel').toggleClass('disabled');
  $('#new-contact-task-spinner').toggleClass('invisible');

  $('#new-contact-task-form').submit();
}

function clearNewContactTaskForm() {
  $('#new-contact-task-form')[0].reset();

  $('#new-contact-task-add').removeClass('disabled');
  $('#new-contact-task-cancel').removeClass('disabled');
  $('#new-contact-task-spinner').removeClass('invisible');

  $('#new-contact-task-panel').fadeOut();
}

function submitConversationsSendMessageForm(e) {
  e.preventDefault();

  if($('#contact-conversations-text-message').val() == ''){
    return false;
  }

  $('#contact-conversations-text-message').toggleClass('disabled');
  $('#contact-conversations-text-button').toggleClass('hidden');
  $('#contact-conversations-text-spinner').toggleClass('hidden');
  $("#conversations-send-message-form :input").prop("readonly", true);
}

var taglist = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '/admin/next/list_tags'
});

function newTouchpoint(e) {
  $('.touchpoint').addClass('disabled');

  var form = $('#new-contact-task-form');

  form.find('select[name="task[task_type]"]').val(e.data.type);
  form.find('input[name="task[title]"]').val(e.data.title);
  form.find('input[name="task[touchpoint]"]').val('true');

  form.submit();
}

function archiveContacts() {
  swal({
    title: 'Archive ' + selectedContacts.length + ' contacts',
    text: 'This will permanently remove all pending tasks and hide these contacts from your view. Are you sure you want to archive?',
    type: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Yes, archive them!',
    cancelButtonText: 'Nevermind'
  }).then((result) => {
    if (result.value) {
      $('#mass-action-option').val('archive');
      $('#mass-action-contact-id').val(selectedContacts.map((c) => c.id ));
      $('#mass-action-form').submit();
    } else {
      return;
    }
  })
}

function archiveSingleContact(id) {
  swal({
    title: 'Archive contact',
    text: 'This will permanently remove all pending tasks and hide this contact from your view. Are you sure you want to archive?',
    type: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Yes, archive it!',
    cancelButtonText: 'Nevermind'
  }).then((result) => {
    if (result.value) {
      $('#mass-action-contact-id').val(id);
      $('#mass-action-option').val('archive');
      $('#mass-action-form').submit();
    } else {
      return;
    }
  })
}

function cancelBulkTagging() {
  $('.typeahead-tags').tagsinput('removeAll');
}

function bulkUpdateTags() {
  $('#mass-action-option').val('tags');
  $('#mass-action-contact-id').val(selectedContacts.map((c) => c.id ));
  $('#mass-action-add-tags').val($('#bulk-add-tags-field').val());
  $('#mass-action-remove-tags').val($('#bulk-remove-tags-field').val());

  $('#mass-action-form').submit();
}

app.ready(function() {
  taglist.initialize();

  $('#typeahed-tags').tagsinput({
    typeaheadjs: {
      name: 'taglist',
      source: taglist.ttAdapter(),
      displayKey: 'name',
      valueKey: 'name'
    }
  });

  $('.typeahead-tags').tagsinput({
    typeaheadjs: {
      name: 'taglist',
      source: taglist.ttAdapter(),
      displayKey: 'name',
      valueKey: 'name'
    }
  });

  $('#conversations-send-message-form').on('submit', submitConversationsSendMessageForm);

  $('#new-send-email-touchpoint').click({ type: 'email', title: 'Email' }, newTouchpoint);
  $('#new-message-touchpoint').click({ type: 'message', title: 'Text' }, newTouchpoint);
  $('#new-phone-call-touchpoint').click({ type: 'phone_call', title: 'Phone call' },newTouchpoint);
  $('#new-meeting-touchpoint').click({ type: 'meeting', title: 'Meeting' },newTouchpoint);
  $('#new-general-touchpoint').click({ type: 'general', title: 'General' },newTouchpoint);

  observeTaskPanelForCKEditor();

  $('.archived form input').attr('readonly', 'readonly');
  $('.archived form button').attr('disabled', 'disabled');

  var utilsScriptPath = $('[data-utils-script]').data('utilsScript');
  var telInput = elm => {
    var t = window.intlTelInput(elm, { utilsScript: utilsScriptPath });
    // elm.addEventListener('countrychange', () => { return; });
    var $elm = $(elm);
    $elm.change(() => {
      var $feedback = $elm.closest('.form-group').find('.invalid-feedback');
      t.setNumber(elm.value)
      if (elm.value.length) {
        var action = $elm.closest('form').attr('action');
        action = action.match(/\d+/) ? action : action + '/new';
        $.get(action + '/phone_validate', { number: t.getNumber() }, (data) => {
          if (data.message) {
            $elm.addClass('is-invalid');
            $feedback.html(`<ul class="list-unstyled"><li>${data.message}</li></ul>`).show();
          } else {
            $elm.removeClass('is-invalid');
            $feedback.html('');
          }
        });
      } else {
        $elm.removeClass('is-invalid');
        $feedback.html('');
      }
    });
    return t;
  }

  var telInputs = [];
  $('form input[type="tel"]').each((i, input) => {
    telInputs.push(telInput(input));
  });

  $('[data-add="phone"]').click(e => {
    var $newrow = $('#phone-row-template').clone();
    $newrow.find('select').selectpicker({
      iconBase: '',
      tickIcon: 'ti-check',
      style: 'btn-light'
    });
    $newrow.toggleClass('hidden').appendTo('#phone-rows');
    telInputs.push(telInput($newrow.find('input[type="tel"]')[0]));
  });

  $('#tab_contact_details, #new-contact-form').validator().on('submit', (e) => {
    if (e.isDefaultPrevented()) {
    } else {
      var $feedback = $(e.target).find('.invalid-feedback > ul');
      if ($feedback.length) {
        e.preventDefault();
        var $input = $feedback.closest('.form-group').find('.form-control');
        $([document.documentElement, document.body]).animate({
          scrollTop: ($input.offset().top - 100)
        }, 200);
        $input.focus();
      } else {
        $('#new-contact-add').addClass('disabled');
        $('#new-contact-cancel').addClass('disabled');
        $('#new-contact-spinner').removeClass('invisible');
        telInputs.forEach((elm) => { elm.a.value = elm.getNumber() });
      }
    }
  });

  window.contactListFilter = {};

  $('#contact-search').keyup((e) => {
    window.contactListFilter.printName = e.target.value.toLowerCase();
    $('#contacts-table').jsGrid('search', window.contactListFilter);

    if (selectedContacts.length > 0) {
      selectedContacts = [];
      $('#mass_action_btns').hide();
      window.contactList.forEach(function(c) {
        c.Selected = false;
        $("#contacts-table").jsGrid("updateItem", c, c);
      });
    }
  });

  // Intially hide mass action button group
  $('#mass_action_btns').hide();

  $('#modal-bulk-tag').on('show.bs.modal', function () {
    document.getElementById("tag-contact-num").textContent = selectedContacts.length;
  });

  $("#sort").on('change', function(event) {
    var field = $(this).find(':selected').data('field');
    var order = $(this).find(':selected').data('order');
    $('#contacts-table').jsGrid('sort', { field: field, order: order });
  });

  $("#statusFilter").on('change', function(event) {
    window.contactListFilter.salesStage = this.value;
    $('#contacts-table').jsGrid('search', window.contactListFilter);
  });

  $("#tagFilter").on('change', function(event) {
    window.contactListFilter.tags = this.value;
    $('#contacts-table').jsGrid('search', window.contactListFilter);
  });

  $("#pageSize").on('change', function(event) {
    $("#contacts-table").jsGrid("option", "pageSize", this.value);
  });

  ClassicEditor
    .create(document.querySelector('.h-editor'), {
      toolbar: [ 'bold', 'italic', 'link', 'bulletedList' ]
    })
    .then(function(editor){
      window.h_ckeditor = editor;

      $('input, .ck-content').on('keydown input change', function() {
        $(this).closest("form").find('.save-changes-bar').removeClass('hidden');
      });
    })
    .catch(function(error){
      console.error(error);
    });
});

var selectedContacts = [];

$("#contacts-table").jsGrid({
  width: "100%",
  height: "auto",
  selecting: false,
  paging: true,
  pageSize: 15,
  pageButtonCount: 3,
  pagerFormat: "{first} {prev} {pages} {next} {last}",
  autoload: true,
  controller: {
    loadData: function(filter) {
      var d = $.Deferred();

      if (window.contactList) {
        var regex = new RegExp(filter.printName || '', 'i');

        d.resolve(window.contactList.filter(function (row){
          if (filter.salesStage && row.salesStageClass != filter.salesStage) {
            return false;
          }

          if (filter.tags && (row.tags.length == 0 || !row.tags.find((tag) => tag.name == filter.tags))) {
            return false;
          }

          return regex.test(row.printName);
        }));
      } else {
        $.ajax({
          url: "/admin/next/contacts.json",
          dataType: "json"
        }).done(function(response) {
          window.contactList = response;
          d.resolve(window.contactList);
        });
      }

      return d.promise();
    }
  },

  fields: [
      {
        headerTemplate: function() {
          return `<span class="pl-20"></span>`;
        },
        itemTemplate: function(_, item) {
          return $("<input>").addClass("ml-15 contact-checkbox").attr("type", "checkbox").prop("checked", item.Selected).on("click", function() {
            item.Selected = !item.Selected;

            if (item.Selected) {
              selectedContacts.push(item);
            } else {
              selectedContacts = selectedContacts.filter(function(e) { return e !== item })
            }

            selectedContacts.length > 0 ? $('#mass_action_btns').show() : $('#mass_action_btns').hide();
          });
        },
        align: "center",
        width: 40,
        sorting: false,
        css: "d-none d-md-table-cell"
      },
      {
        headerTemplate: function() {
          return `<span class="text-fade pl-30 fs-14">General Info</span>`;
        },
        itemTemplate: function(_, item) {
         return `
            <a href="/admin/next/contacts/${item.id}" class="media">

                <span class="avatar avatar-xl contact ${item.salesStageClass}-stage">${item.initials}</span>
                <div class="media-body">
                  <h6 class="lh-1">${item.printName} | <span class="text-${item.salesStageClass}">${item.salesStage}</h6>
                  <small>Added ${item.createdDate}</small>
                </div>

            </a>
          `;
        },
        align: "left",
        width: "auto",
        sorting: false,
        css: "contact-details"
      },
      {
        headerTemplate: function() {
          return `<span class="text-fade fs-14">Tags</span>`;
        },
        itemTemplate: function(_, item) {
          var result = "";

          result = item.tags.slice(0,3).map(function(tag) {
            return `
              <span class="badge badge-secondary ml-0">${tag.name}</span>
            `;
          }).join('');

          if (item.tags.length > 3) {
            var tags_list = item.tags.slice(3).map(function(tag) {
              return `
                <span class="badge badge-secondary ml-0">${tag.name}</span>
              `;
            }).join('');

            result = `
              ${result}
              <div class="dropdown table-action" style="display: inline-block;">
                <span class="dropdown-toggle no-caret hover-primary pl-10" data-toggle="dropdown"><span class="badge badge-gray ml-0">+${item.tags.length - 3}</span></span>
                <div class="dropdown-menu dropdown-menu-right p-2">${tags_list}</div>
              </div>
            `;
          }

          return result;
        },
        align: "left",
        width: "auto",
        sorting: false,
        css: "d-none d-xl-table-cell w-350px"
      },
      {
        headerTemplate: function() {
          return "";
        },
        itemTemplate: function(_, item) {
          return `
            <div class="dropdown table-action">
              <span class="dropdown-toggle no-caret hover-primary" data-toggle="dropdown"><i class="ti-more-alt rotate-90"></i></span>
              <div class="dropdown-menu dropdown-menu-right">
                <a class="dropdown-item" href="#" onclick="archiveSingleContact(${item.id})"><i class="ti-trash"></i> Archive</a>
              </div>
            </div>
          `;
        },
        align: "left",
        width: "40",
        sorting: false
      },
      {
        type: "number",
        name: "id",
        visible: false,
      },
      {
        type: "text",
        name: "printName",
        visible: false,
      },
      {
        type: "text",
        name: "lastName",
        visible: false,
      },
      {
        type: "text",
        name: "salesStageClass",
        visible: false,
      }
  ]
});
