function submitNewCampaignForm() {
  $('#new-campaign-add').toggleClass('disabled');
  $('#new-campaign-cancel').toggleClass('disabled');
  $('#new-campaign-spinner').toggleClass('invisible');

  $('#new-campaign-form').submit();
}

function addNewCampaignStep() {
  $('#new-campaign-step-form').submit();
}

function clearNewCampaignStepForm() {
  $('#new-campaign-step-form')[0].reset();

  $("#new-campaign-step-add-button").toggleClass('btn-primary btn-warning disabled');
  $("#new-campaign-step-add-button > i").toggleClass('ti-plus ti-more');

  $('#new-campaign-step-panel').fadeOut();

  $('#new-campaign-step-add').toggleClass('disabled');
  $('#new-campaign-step-cancel').toggleClass('disabled');
  $('#new-campaign-step-spinner').toggleClass('hidden');
}

function clearEditCampaignStepPanel() {
  $('#edit-campaign-step-panel').fadeOut();
  $('#edit-campaign-step-panel').html('');
}

function updateCampaignStep() {
  $('#update-campaign-step-form').submit();
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

$('document').ready(function(){

  $('#new-campaign-step-schedule-button').length &&
    $('#new-campaign-step-schedule-button').on('click', function(e) {
      $('#new-campaign-step-immediate-button').removeClass('btn-info');
      $('#new-campaign-step-schedule-button').addClass('btn-info');
      $('#new-campaign-step-timming-panel').show();

      e.preventDefault();
    });

  $('#new-campaign-step-immediate-button').length &&
    $('#new-campaign-step-immediate-button').on('click', function(e) {
      $('#new-campaign-step-immediate-button').addClass('btn-info');
      $('#new-campaign-step-schedule-button').removeClass('btn-info');
      $('#new-campaign-step-timming-panel').hide();

      $("#new-campaign-step-form input[name='campaign_step[due_on_value]']").val('');
      $("#new-campaign-step-form select[name='campaign_step[due_on_unit]']").prop('selectedIndex', 0);

      e.preventDefault();
    });

  $('#new-campaign-step-form').validator().on('submit', function (e) {
    if (e.isDefaultPrevented()) {
      console.log(2222)
      e.preventDefault();
      e.stopPropagation();
    }
    else {
      $('#new-campaign-step-add').toggleClass('disabled');
      $('#new-campaign-step-cancel').toggleClass('disabled');
      $('#new-campaign-step-spinner').toggleClass('invisible');
    }
  });

  $('#new-campaign-step-add-button').on('click', function(e) {
    $('#new-campaign-step-panel').toggle();
    $('#new-campaign-step-add-button').toggleClass('btn-primary btn-warning disabled');
    $("#new-campaign-step-add-button > i").toggleClass('ti-plus ti-more');
  });

  $(document).on('changed.bs.select', '#update-campaign-associated-forms', function(e) {
    $('#update-campaign-form').trigger('submit.rails');
  });

  $("#subscribers-table").jsGrid({
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
          loadSubscribers(d);
        }

        return d.promise();
      }
    },

    fields: [
        {
          headerTemplate: function() {
            return `<span class="text-fade pl-30 fs-14">General Info</span>`;
          },
          itemTemplate: function(_, item) {
           return `
              <a href="/admin/next/contacts/${item.id}" class="media">

                  <span class="avatar avatar-xl contact ${item.salesStageClass}-stage">${item.initials}</span>
                  <div class="media-body">
                    <h6 class="lh-1">${item.printName} | <span class="text-${item.salesStageClass}">${item.salesStage}</span></h6>
                    <small>Added ${item.createdDate}</small>
                    <h6>${item.subscriptionStatus} ${item.nextStep ? '| Next step: ' + item.nextStep : ''}</h6>
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
            return "";
          },
          itemTemplate: function(_, item) {
            if (item.subscriptionStatus == 'Running') {
              return `
                <div class="dropdown table-action">
                  <span class="dropdown-toggle no-caret hover-primary" data-toggle="dropdown"><i class="ti-more-alt rotate-90"></i></span>
                  <div class="dropdown-menu dropdown-menu-right">
                    <a class="dropdown-item" href="#" onclick="removeSubscriber(${item.id})"><i class="ti-trash"></i> Remove</a>
                  </div>
                </div>
              `;
            }
            else {
              return "";
            }
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
            return 'The code is reserved for system snippet.'
          } else if (isLabelValueValid() === false) {
            return 'Please limit the code characters to letters, numbers, undescores and/or hyphens.'
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
