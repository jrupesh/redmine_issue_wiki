require 'redmine'

module WikiMacros
  Redmine::WikiFormatting::Macros.register do
    desc  "Displays Issue Wiki Sections.\n" +
          "!{{iwsection(id)}}\n" +
          "The project sections can be created at Project settings."
    macro :iwsection do |obj, args|
      return unless @project
      return unless obj.respond_to?(:page)
      page    = obj.page
      begin
        sect_id = args[0].strip.to_i if args[0]
        iws = IssueWikiSection.find(sect_id)
        raise 'Section object nil' if iws.nil?
      rescue
        return ''
      end
      sec_group = !iws.section_group.nil? ? iws.section_group.downcase : ""
      s = ""
      s << "<div class='issue_wiki #{sec_group} iws_contextual '>"
      if !iws.review_opts.nil? && iws.review_opts.to_i > 0 && User.current.allowed_to?(:vote_issue_wiki, @project)
        
        s << link_to("", issue_wiki_votes_path(:id => page.issue_id,:value => 1, :sec_id => iws.id),
          :method => :post, :remote => true ,:id => "tab-#{Redmine::Utils.random_hex(4)}", :class => "voting_btn up_button" )
        s << "<span class='up_votes-#{iws.id}'>#{page.total_iw_vote_up(iws)}</span>"
        s << link_to("", issue_wiki_votes_path(:id => page.issue_id,:value => -1, :sec_id => iws.id),
          :method => :post, :remote => true ,:id => "tab-#{Redmine::Utils.random_hex(4)}", :class => "voting_btn down_button")
        s << "<span class='down_votes-#{iws.id}'>#{page.total_iw_vote_down(iws)}</span>"
      end
      if User.current.allowed_to?(:add_issue_wiki_comments, @project)
        url = url_for(:only_path => true, :controller => 'issue_wiki_comments', :action => 'new',
          :id =>  page.issue_id, :wiki_id => page.id, :section_id => iws.id, :format=>:js)

        # url = @_controller.controller_name == "issue_wiki" ? issue_wiki_comments_edit_path(page.issue,iws.id) : 
        #       wiki_comments_edit_path(:id => @project.id, :wiki_id => page.id, :section_id => iws.id)

        s << link_to_function("", "showIssueWikiCommentForm('#{iws.id}','#{url}');",
          :class => "issue_wiki icon #{sec_group} icon-comment")
        # s << "<span/>"
      end
      s << "</div>"
      raw "<#{iws.wikiformat} class='issue_wiki #{sec_group}'>#{iws.heading}</#{iws.wikiformat}>#{raw s.html_safe}<div class='issue_wiki #{sec_group}' >".html_safe
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc  "Displays Issue Wiki Sections.\n" +
          "!{{endiwsection}}\n" +
          "The project sections are created in Project settings."
    macro :endiwsection do |obj, args|
      return unless @project
      return unless obj.respond_to?(:page)
      begin
        sect_id = args[0].strip.to_i if args[0]
        iws = IssueWikiSection.find(sect_id)
        raise 'Section object nil' if iws.nil?
      rescue
        iws = nil
      end

      s = ""

      if !iws.nil?
        sec_group = !iws.section_group.nil? ? iws.section_group.downcase : ""
        if User.current.allowed_to?( :view_issue_wiki_comments, @project) && Comment.exists?(:issue_wiki_section_id => iws.id,
          :commented_id => obj.page.id, :commented_type => "WikiPage" )
          s << "<fieldset id='comments_container-#{iws.id}' class='issue_wiki #{sec_group} comments_container collapsible'>"
          url = issue_wiki_comments_path(:id => obj.page.issue,:section_id => iws.id)
          s << link_to_function(l(:label_comment_plural), "loadIssueWikiComments(this, '#{iws.id}','#{url}');",
            :class => "issue_wiki #{sec_group} collapse")
          s << "</fieldset>"
        end
        s << "<div id='comments_form-#{iws.id}'></div>" if User.current.allowed_to?(
          :add_issue_wiki_comments, @project)
      end

      raw "#{raw s.html_safe}</div>".html_safe
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc  "Displays User defined Issue Wiki Sections.\n" +
          "!{{usersection(text)}}\n" +
          "!{{usersection(text,html_header)}}\n" +
          "!{{usersection(text,html_header,group)}}\n"
    macro :usersection do |obj, args|
      return unless @project
      return unless obj.respond_to?(:page)
      page      = obj.page
      text      = args[0] ? args[0].strip.gsub(/'|"/,"") : "User Section"
      html_tag  = args[1] ? args[1].strip.gsub(/'|"/,"") : "h1"
      html_cls  = args[2] ? args[2].strip.gsub(/'|"/,"") : "issue_wiki"
      raw "<#{html_tag} class='issue_wiki iw_user_section #{html_cls}'>#{text}</#{html_tag}><div class='issue_wiki iw_user_section #{html_cls}'>".html_safe
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc  "Displays Issue Wiki Sections Tabs.\n" +
          "!{{iwtabs}}\n"
    macro :iwtabs do |obj, args|
      return unless @project
      txt = ""
      if @project.issue_wiki_sections.any?
        txt << "<ul class='issue_wiki_tabs'>"
        @project.issue_wiki_sections.map(&:section_group).uniq.reject{ |u| u.nil? }.each do |sg|
          txt << "<li class='iwt #{sg.downcase}'>"
          txt << link_to(sg.titleize, "javascript:void(0);", :id => "tab-#{Redmine::Utils.random_hex(4)}", :class => "iwtabs #{sg.downcase}",
                :onclick => "showIssueWiki('#{sg.downcase}');")
          txt << "</li>"
        end

        txt << "<li id='issue_wiki_user_tab' class='iwt iw_user'>"
        txt << link_to(l(:label_iw_user_defined), "javascript:void(0);", :id => "tab-#{Redmine::Utils.random_hex(4)}", :class => "iwtabs iw_user",
              :onclick => "showIssueWiki('iw_user_section');")
        txt << "</li>"        

        txt << "<li class='iwt showall'>"
        txt << link_to(l(:button_show), "javascript:void(0);", :id => "tab-#{Redmine::Utils.random_hex(4)}", :class => "iwtabs showall",
              :onclick => "showAllIssueWiki();")
        txt << "</li>"        

        txt << "</ul>"
      end
      raw txt.html_safe
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Displays a comment form."
    macro :comment_form do |obj, args|
      return unless @project
      return unless obj.respond_to?(:page)
      unless User.current.allowed_to?(:add_issue_wiki_comments, @project)
        return ''
      end
      page      = obj.page
      num = Redmine::Utils.random_hex(4)
      area_id = "add_comment_area_#{num}"
      div_id = "add_comment_form_div#{num}"

      o = @_controller.send(:render_to_string, {:partial => "comments/form", :locals =>{:object => page, :area_id => area_id, :div_id => div_id}})
      o << raw(wikitoolbar_for(area_id))
      raw o.html_safe
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Display comments of the page."
    macro :comments do |obj, args|
      return unless @project
      return unless obj.respond_to?(:page)
      unless User.current.allowed_to?(:view_issue_wiki_comments, @project)
        return ''
      end
      page      = obj.page

      data = page.wiki_extension_data
      comments = WikiExtensionsComment.where(:wiki_page_id => page.id).all

      raw display_comments_tree(comments,nil,page,data)

    end
  end
  
end
