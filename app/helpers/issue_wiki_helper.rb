module IssueWikiHelper
  def edit_issue_wiki_sections(page, text,project,master_edit=false)
    s = ""
    if project.issue_wiki_sections.any? && text && !master_edit && project.module_enabled?(:wiki_templates)

      cur_sections = project.issue_wiki_sections.collect { |iws| "{{iwsection(#{iws.id})}}" }

      page.get_issue_wiki_sections.each do |heading,sub_text|
        cur_sections.delete(heading) if cur_sections.include?(heading)
        next if heading.start_with?("{{usersection") && ( sub_text.strip.blank? ||
          ( sub_text == "h1. WIKI-#{@issue.id}" ))
        s << issuewikiformfields(heading,sub_text)
      end
      cur_sections.each { |heading| s << issuewikiformfields(heading,"") } if cur_sections.any?
    else
      text_id = Redmine::Utils.random_hex(4)
      s << text_area_tag('content[text]', text, :cols => 100, :rows => 20,
          :class => 'wiki-edit', :accesskey => accesskey(:edit), :id => "content_sectiontext_#{text_id}")
      s << wikitoolbar_for("content_sectiontext_#{text_id}")
    end
    s.html_safe
  end

  def issuewikiformfields(heading,sub_text)
    s = ""
    if heading.start_with?("{{iwtabs}}")
      s << hidden_field_tag('content[sectiontext][]', heading)
    else
      text_id = Redmine::Utils.random_hex(4)
      heading.start_with?("{{usersection") ? s << getusersectionlabel(heading) : s << getsectionlabel(heading)
      s << hidden_field_tag('content[sectiontext][]', heading)
      s << text_area_tag('content[sectiontext][]', sub_text, :cols => 100, :rows => 5,
        :class => 'wiki-edit', :id => "content_sectiontext_#{text_id}")
      # s << hidden_field_tag('content[sectiontext][]', "{{endiwsection}}")
      s << hidden_field_tag('content[sectiontext][]', heading.gsub("iwsection","endiwsection").gsub("usersection","endiwsection"))
      s << wikitoolbar_for("content_sectiontext_#{text_id}")
    end
    s
  end


  def getsectionlabel(sectionlabel)
    id = sectionlabel.scan(/\d*/)
    begin
      iws = IssueWikiSection.find(id.join("").to_i)
      return def_label_tag_section(sectionlabel, "Could not find Section #{sectionlabel}" ) if iws.nil? 
      return "<#{iws.wikiformat}>#{iws.heading}</#{iws.wikiformat}>"
    rescue
      return def_label_tag_section(sectionlabel)
    end
  end

  def getusersectionlabel(sectionlabel)
    sect_array = sectionlabel.gsub(/{{usersection|\(|\)|}}/,"").gsub(/'|"/,"").split(",")
    html_tag  = sect_array[1] || "h1"
    html_cls  = sect_array[2].nil? ? "class=#{sect_array[2]}" : ""
    heading   = sect_array[0] || "User Section"
    "<#{html_tag} #{html_cls}>#{heading}</#{html_tag}>"
  end

  def def_label_tag_section(s,scontent=nil)
    label_tag(s, scontent, :style => "margin-left:0px")
  end

  def get_iw_comments(comment,page,level="")
    s = ""
    level = "level" + comment.ancestors.length.to_s if level.blank?
    s << "<div id='comment_for-#{comment.id}' class='noteclassic #{level}'>"
    s << "<div class='contextual'>"
    s << link_to_if_authorized(image_tag('edit.png'), {:controller => 'issue_wiki_comments', :action => 'edit', :id => comment.id,
      :wiki_id => page }, :method => :get, :remote => true, :title => l(:button_edit)) if comment.author == User.current || User.current.admin?
    s << link_to_if_authorized(image_tag('delete.png'), {:controller => 'issue_wiki_comments', :action => 'destroy', :id => comment.id, :wiki_id => page },
      :data => {:confirm => l(:text_are_you_sure)}, :remote => true, :method => :delete, :title => l(:button_delete))
    s << "</div>"
    s << "<h4>"
    s << avatar(comment.author, :size => '24')
    s << authoring(comment.created_on, comment.author)
    s << "</h4>"
    s << textilizable(comment.comments)
    s << "<div class='contextual'>"
    s << link_to_if_authorized(l(:button_reply), {:controller => 'issue_wiki_comments', :action => 'new', :wiki_id => page,
      :parent_id => comment.id }, :method => :get, :remote => true, :title => l(:button_reply))
    s << "</div>"
    s << "</div>"
    # s << "<div id='edit_comment_container-#{comment.id}' style='display:none;'></div>"
    s.html_safe
  end
end