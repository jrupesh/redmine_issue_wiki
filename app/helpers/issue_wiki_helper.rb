module IssueWikiHelper
  def edit_issue_wiki_sections(page, text,project,master_edit=false)
    s = ""
    if project.issue_wiki_sections.any? && text && !master_edit

      cur_sections = project.issue_wiki_sections.collect { |iws| "{{iwsection(#{iws.id})}}" }

      page.get_issue_wiki_sections.each do |heading,sub_text|
        cur_sections.delete(heading) if cur_sections.include?(heading)
        next if heading.start_with?("{{usersection") && ( sub_text.strip.blank? ||
          ( sub_text == "h1. WIKI-#{@issue.id}" ))
        s << issuewikiformfields(heading,sub_text)
      end
      cur_sections.each { |heading| s << issuewikiformfields(heading,"") } if cur_sections.any?
    else
      s << text_area_tag('content[text]', text, :cols => 100, :rows => 20,
          :class => 'wiki-edit', :accesskey => accesskey(:edit))
    end
    s.html_safe
  end

  def issuewikiformfields(heading,sub_text)
    s = ""
    if heading.start_with?("{{iwtabs}}")
      s << hidden_field_tag('content[sectiontext][]', heading)
    else
      heading.start_with?("{{usersection") ? s << getusersectionlabel(heading) : s << getsectionlabel(heading)
      s << hidden_field_tag('content[sectiontext][]', heading)
      s << text_area_tag('content[sectiontext][]', sub_text, :cols => 100, :rows => 5,
        :class => 'wiki-edit')
      s << hidden_field_tag('content[sectiontext][]', "{{endiwsection}}")
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

end