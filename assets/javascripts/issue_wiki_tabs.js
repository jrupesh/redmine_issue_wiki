$(document).ready(function(){

  show_only_comments();

  function show_only_comments() {
    $('a#tab-issue-comments').addClass('selected');
    $('a#tab-issue-all').removeClass('selected');
    $('a#tab-issue-wiki').removeClass('selected');
    $('.journal.has-notes.has-details .details, .journal.has-details').hide();
    $('.journal.has-notes').show();
    $('#issue-wiki').hide();
  }

  function show_history() {
    $('a#tab-issue-comments').removeClass('selected');
    $('a#tab-issue-wiki').removeClass('selected');
    $('a#tab-issue-all').addClass('selected');
    $('.journal.has-notes.has-details .details,.journal.has-notes.has-details, .journal.has-details, .journal').show();
    $('#issue-wiki').hide();
  }

  $('a#tab-issue-all').bind("click",function(e){
    show_history();
  });

  $('a#tab-issue-comments').bind("click",function(e){
    show_only_comments();
  });
  /*
  $('a#tab-issue-wiki').bind("click",function(e){
    var i = "0";
    show_wiki(i);
  });
  
  $('#tab-issue-wiki').bind("ajax:beforeSend", function(xhr, opts){toggle_wiki(xhr,opts);});
  $('#tab-issue-wiki').bind("ajax:error", function(evt, data, status, xhr){});
  */
});

function show_wiki(id){
  $('a#tab-issue-wiki').addClass('selected');
  $('a#tab-issue-all').removeClass('selected');
  $('a#tab-issue-comments').removeClass('selected');
  $('.journal.has-notes.has-details .details,.journal.has-notes.has-details, .journal.has-details, .journal').hide();

  if ($('#tab-issue-wiki').hasClass("loaded") == true){
      $('#tab-issue-wiki').show();
      return false;
    };
  $.ajax({
    url: "issuewiki?id="+String(id),
    type: 'post',
    data: $('#tab-issue-wiki').serialize()
  });
  return true;
};
