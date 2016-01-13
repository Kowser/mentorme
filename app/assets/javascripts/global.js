var loadingBar =
'<div class="progress progress-striped active loading-bar">' +
  '<div class="progress-bar progress-bar-primary " role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%">Loading...</div>' +
'</div>'

var calendar_options = {
  dateFormat : 'mm/dd/yy',
  changeMonth : true,
  changeYear : true
}

$(document).on('page:change', function() {
  $('select#organization_id').change(function() {
    var org_id = window.location.toString().match(/organizations\/(\d+)/)[1]
    window.location = window.location.toString().replace("organizations/" + org_id, "organizations/" + $(this).val())
  });

  $('a[data-toggle="collapse"]').click(function() {
    $(this).children('i').toggleClass('fa-plus fa-minus');
  });

  $('select#user_ethnicity').change(function() {
    var select = $(this).val();
    if(select === 'Other') {
      $('div#user_ethnicity_other').show();
    } else {
      $('div#user_ethnicity_other').hide();
    }
  });

  // CALENDAR FUNCTIONS
  $('input.calendar').datepicker(calendar_options);

  $("#user_birth_date").datepicker(
    $.extend({
      defaultDate: '-12y',
      yearRange: '-99y:c+nn',
      maxDate: '-6y'
    }, calendar_options)
  );

  $("#background_check_dob").datepicker({
    dateFormat : 'yy/mm/dd',
    yearRange: '-99y:c+nn',
    maxDate: '-18y',
    changeMonth : true,
    changeYear : true
  });

  $("#check_in_date").datepicker(
    $.extend({
      maxDate: '0d',
      minDate: '-2y'
    }, calendar_options)
  );

  $("#check_in_next_date").datepicker(
    $.extend({
      defaultDate: '+7d',
      minDate: '-2y',
      maxDate: '2m'
    }, calendar_options)
  );

  $("#goal_deadline").datepicker(
    $.extend({
      minDate: '-6m',
      maxDate: '6m'
    }, calendar_options)
  );
  // end CALENDAR FUNCTIONS

  $('select#organizations_user_active').change(function() {
    $(this).closest('form').submit();
  });

  $('#reference_contacted').change(function() {
    $(this).closest('form').submit();
  });

  function destroy() {
    $('.destroy').click(function() {
      if (prompt("WARNING: Type 'DESTROY' to delete. This is permanent!") === 'DESTROY') {
        $(this).closest('tr').addClass('destroy-element');
      } else {
        return false;
      }
    });
  }
  destroy();

  function trash() {
    $('.trash').click(function() {
      if (confirm("Delete item?")) {
        $(this).closest('div.panel-heading').next().find('input[type=hidden]').first().val('true');
        $(this).closest('div.panel').hide();
      }
      return false;
    });
  }
  trash();

  // CHECK_INS
  $('select#search_match_id').change(function() {
    $(this).closest('form').submit();
    $('div#check-ins-index-panel').find('table').replaceWith(loadingBar);
  });

  $('select#match_id').change(function() {
    var match_id = $(this).val();
    $('div#attendees').empty().append(loadingBar);
    $.ajax({ url: "/check_ins/attendees/" + match_id });
  });

  $('.delete-file-link').click(function() {
    if (confirm("Delete file: Are you sure?")) {
      $(this).closest('tr').remove();
    } else {
     return false;
    }
  });

  // GOALS
  $('.delete-goal-link').click(function() {
    if (confirm("Permanently delete Goal?")) {
      $(this).closest('tr').remove();
    } else {
     return false;
    }
  });

  $('select#search_match_id').change(function() {
    $(this).closest('form').submit();
    $('div#goals-index-panel').find('table').replaceWith(loadingBar);
  });

  $('input#completed').click(function() {
    if (confirm("Goal Completed and ready for review?")) {
      var form = $(this).parent('form');
      form.find("span").text("Completed");
      form.submit();
      $(this).closest('tr').remove();
    } else {
      return false;
    }
  });

  $('input#verify').click(function() {
    if (confirm("Goal verified? This is permanent.")) {
      var form = $(this).parent('form');
      form.find("span").text("Verified");
      form.submit();
      $(this).remove();
    } else {
      return false;
    }
  });

  $('select#selected_match_type').change(function() {
    var type = $(this).val();
    if(type === 'All Matches') {
      $('div#hidden').hide();
      $('div#match_ids').empty().append('<input id="match_ids_" name="match_ids[]" type="hidden" value="all">');
    } else if(type === 'selected_matches') {
      $('div#hidden').hide();
      $('div#match_ids').empty().append(loadingBar);
      $(this).closest('form').submit();
    } else if(type === 'specific_match') {
      $('div#match_ids').empty()
      $('div#hidden').show();
    }
  });

  $('select#selected_match_id').change(function() {
    $(this).closest('form').submit();
    $('div#match_ids').empty().append(loadingBar);
  });
  // end GOALS

  // CUSTOM FORMS
  function addQuestion() {
    $('#add-question').click(function() {
      var id = Math.floor(Math.random() * (100000)) + 9999;
      var regexp = RegExp($(this).data('id'), 'g');
      $(this).before($(this).data('fields').replace(regexp, id));
      trash();
      return false;
    });
  }
  addQuestion();

  // CUSTOM ENROLLMENTS
  function addStep() {
    $('#add-step').click(function() {
      var id = Math.floor(Math.random() * (100000)) + 9999;
      var regexp = RegExp($(this).data('id'), 'g');
      $(this).before($(this).data('fields').replace(regexp, id));
      trash();
      selectStepType();
      return false;
    });
  }
  addStep();

  function selectTemplate() {
    $("select.template-selector").change(function() {
      var template = $(this).val();
      var index = $(this).attr('id').match( /\d+/g)[0];
      var fields = $(this).closest('div.template-selector').siblings('div.template-fields');
      if (template !== "") {
        fields.empty().append(loadingBar).addClass('insert-here');
        $.ajax({ url: "/enrollments/template_fields/?template="+template+"&child_index="+index });
        return false;
      }
    });
  }
  selectTemplate();

  function selectStepType() {
    $("select.step-type").change(function() {
      var type = $(this).val();
      var index = $(this).attr('id').match(/\d+/g)[0];
      var form_selector = $(this).closest('div.row').next('div.form-selector');
      var url = window.location.toString().match(/\/(\d+)\//g);
      var org_id = url[0].replace(/\//g, "");
      var enroll_id = 0
      if (url[1] !== undefined) {
        var enroll_id = url[1].replace(/\//g, "");
      }

      form_selector.empty().append(loadingBar).addClass('insert-here');
      parameters = "?step_type=" + type + "&child_index=" + index + "&organization_id=" + org_id + "&enrollment_id=" + enroll_id

      if (type !== "boolean") {
        $.ajax({ url: "/enrollments/form_select/" + parameters }).done(function() {
          form_selector.next('div.template-selector').bind(selectTemplate());
        });
      } else if (type === "boolean") {
        form_selector.removeClass('insert-here').empty();
      }
      return false;
    });
  }
  selectStepType();
  // end CUSTOM ENROLLMENTS

});
