module IssueWikiHelper
  def edit_issue_wiki_sections(text,project,master_edit=false)
    s = ""
    if project.issue_wiki_sections.any? && text && !master_edit
      get_issue_wiki_sections(text,project).each do |heading,sub_text|
        next if heading.start_with?("{{usersection") && ( sub_text.strip.blank? ||
          ( sub_text == "h1. WIKI-#{@issue.id}" ))
        heading.start_with?("{{usersection") ? s << getusersectionlabel(heading) : s << getsectionlabel(heading)
        s << hidden_field_tag('content[sectiontext][]', heading)
        s << text_area_tag('content[sectiontext][]', sub_text, :cols => 100, :rows => 5,
          :class => 'wiki-edit')
      end
    else
      s << text_area_tag('content[text]', text, :cols => 100, :rows => 20,
          :class => 'wiki-edit', :accesskey => accesskey(:edit))
    end
    s.html_safe
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
    sect_array = sectionlabel.gsub(/{{usersection\(|\)}}/,"").gsub(/'|"/,"").split(",")
    html_tag  = sect_array[1] || "h1"
    html_cls  = sect_array[2].nil? ? "class=#{sect_array[2]}" : ""
    heading   = sect_array[0] || "User Section"
    "<#{html_tag} #{html_cls}>#{heading}</#{html_tag}>"
  end

  def def_label_tag_section(s,scontent=nil)
    label_tag(s, scontent, :style => "margin-left:0px")
  end

  def get_issue_wiki_sections(text,project)
    if text.scan(/{{([^}]*)}}\r?\n(.*?)\r?(?=\n{{|\n?$)/).select{ |k, v| k.start_with? "iwsection" || k == "usersection" }.any? 
      section_array = text.chomp.split(/\r\n|\n/).inject([]) do |a, v|
        if v =~ /{{.*}}/
          a << [v.gsub(/^{{|}}$/, ""), []]
        else
          a.last[1] << v
        end
        a
      end.select{ |k, v| (k.start_with?("iwsection") || k.start_with?("usersection")) }.map{ |k, v| ["{{#{k}}}", v.join("\n")] }
    else
      section_array = []
      project.issue_wiki_sections.each do |iws|
        section_array << [ "{{iwsection(#{iws.id})}}", "" ]
      end
      section_array << [ "{{usersection(User Section,h1)}}", text ] if text && !text.blank?
    end
    # Rails.logger.debug("Printing ARRAY section_array --> #{section_array}\n")
    section_array
  end
end