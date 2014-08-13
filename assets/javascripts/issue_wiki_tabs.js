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

});

function show_wiki(id){
  $('a#tab-issue-wiki').addClass('selected');
  $('a#tab-issue-all').removeClass('selected');
  $('a#tab-issue-comments').removeClass('selected');
  $('.journal.has-notes.has-details .details,.journal.has-notes.has-details, .journal.has-details, .journal').hide();

  if ($('#tab-issue-wiki').hasClass("loaded") == true){
      $('#tab-issue-wiki').show();
      return;
    };
  $.ajax({
    url: String(id)+"/showissuewiki",
    type: 'get'
  })
  .done(function(data) {
    if ( console && console.log ) {
      console.log( "console data:", data );
    };
  })
  .fail(function(jqXHR, textStatus) {
    alert( "Wiki Load failed: " + textStatus );
  });
  return;
};

function addIssueWikiWith(html){
  var replacement = $(html);
  $('#tab-issue-wiki').empty();
  $('#tab-issue-wiki').append(replacement);
};