function addIssueWikiWith(html){
  var replacement = $.parseHTML( html ); // $(html);
  $('#issue-wiki').empty();
  $('#issue-wiki').append(replacement);
  $('#issue-wiki').show();
};

function hideIssueWiki(){
  
  if ( $('.iw_user_section').length == 0 ){ $( "#issue_wiki_user_tab" ).remove(); }
  if ( $('.issue_wiki_tabs li.iwt').length < 3 )
    { $( ".issue_wiki_tabs" ).remove(); }
  else
    {$( ".issue_wiki" ).hide();}
};

function showAllIssueWiki(){
  $( ".issue_wiki" ).show();
  $("a.iwtabs").removeClass("selected")
  $("li.showall a").addClass("selected")
  $('html, body').animate({scrollTop: $(".issue_wiki_tabs li.showall").offset().top}, 100);
};

function showIssueWiki(iwclass){
  hideIssueWiki();
  $("a.iwtabs").removeClass("selected")
  if ( iwclass === "iw_user_section" )
    {$("li.iw_user a").addClass("selected");}
  else
    {$("li."+iwclass+" a").addClass("selected");}
  $( ".issue_wiki."+iwclass ).show();
  var entity = $(".issue_wiki."+iwclass).offset();
  if (entity != undefined)
    {$('html, body').animate({scrollTop: entity.top}, 100);}
};

$(document).ready(function(){

  if ( $('a#tab-issue-comments').length > 0 )
    {show_only_comments();}
  else
    {show_history();}

  hideIssueWiki();

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
      $('#issue-wiki').show();
      return;
    };
  $.ajax({
    url: String(id)+"/showissuewiki.js",
    type: "get"
  })
  .success(function(data){
    // addIssueWikiWith(data); 
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