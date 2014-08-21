require 'redmine'

module WikiMacros
  Redmine::WikiFormatting::Macros.register do
    desc  "Displays Issue Wiki Sections.\n" +
          "!{{iwsection(id)}}\n" +
          "The project sections can be created at Project settings."
    macro :iwsection do |obj, args|
      return unless @project
      return unless obj.respond_to?(:page)
      unless User.current.allowed_to?({:controller => 'issue_wiki', :action => 'show_issue_wiki'}, @project)
        return ''
      end
      page    = obj.page
      begin
        sect_id = args[0].strip.to_i if args[0]
        iws = IssueWikiSection.find(sect_id)
        raise 'Section object nil' if iws.nil?
      rescue
        return ''
      end
      sec_group = !iws.section_group.nil? ? iws.section_group.downcase : ""
      raw "<#{iws.wikiformat} class='issue_wiki #{sec_group}'>#{iws.heading}</#{iws.wikiformat}><div class='issue_wiki #{sec_group}' >".html_safe
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc  "Displays Issue Wiki Sections.\n" +
          "!{{iwsection(id)}}\n" +
          "The project sections can be created at Project settings."
    macro :endiwsection do |obj, args|
      return unless @project
      return unless obj.respond_to?(:page)
      unless User.current.allowed_to?({:controller => 'issue_wiki', :action => 'show_issue_wiki'}, @project)
        return ''
      end
      raw "</div>".html_safe
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
      unless User.current.allowed_to?({:controller => 'issue_wiki', :action => 'show_issue_wiki'}, @project)
        return ''
      end
      page      = obj.page
      text      = args[0] ? args[0].strip.gsub(/'|"/,"") : "User Section"
      html_tag  = args[1] ? args[1].strip.gsub(/'|"/,"") : "h1"
      html_cls  = args[2] ? args[2].strip.gsub(/'|"/,"") : "issue_wiki"
      raw "<#{html_tag} class='#{html_cls} iw_user_section'>#{text}</#{html_tag}><div class='#{html_cls} iw_user_section'>".html_safe
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc  "Displays Issue Wiki Sections Tabs.\n" +
          "!{{iwtabs}}\n"
    macro :iwtabs do |obj, args|
      return unless @project
      unless User.current.allowed_to?({:controller => 'issue_wiki', :action => 'show_issue_wiki'}, @project)
        return ''
      end
      txt = ""
      if @project.issue_wiki_sections.any?
        txt << "<ul class='issue_wiki_tabs'>"
        @project.issue_wiki_sections.map(&:section_group).uniq.reject{ |u| u.nil? }.each do |sg|
          txt << "<li class='iwt #{sg.downcase}'>"
          txt << link_to(sg.titleize, "javascript:void(0);", :id => "tab-#{Redmine::Utils.random_hex(4)}", :class => "iwtabs #{sg.downcase}",
                :onclick => "showIssueWiki('#{sg.downcase}');")
          txt << "</li>"
        end

        txt << "<li id='issue_wiki_user_tab' class='iwt iw_user_section'>"
        txt << link_to(l(:label_iw_user_defined), "javascript:void(0);", :id => "tab-#{Redmine::Utils.random_hex(4)}", :class => "iwtabs iw_user_section",
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
end
