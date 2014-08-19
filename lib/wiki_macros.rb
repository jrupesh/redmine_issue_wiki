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
      raw "<#{iws.wikiformat}>#{iws.heading}</#{iws.wikiformat}>".html_safe
    end
  end
  
  Redmine::WikiFormatting::Macros.register do
    desc  "Displays User defined Issue Wiki Sections.\n" +
          "!{{usersection('text')}}\n" +
          "!{{usersection('text','html_header')}}\n" +
          "!{{usersection('text','html_header','group')}}\n"
    macro :usersection do |obj, args|
      return unless @project
      return unless obj.respond_to?(:page)
      unless User.current.allowed_to?({:controller => 'issue_wiki', :action => 'show_issue_wiki'}, @project)
        return ''
      end
      page      = obj.page
      text      = args[0] ? args[0].strip : "User Section"
      html_tag  = args[1] ? args[1].strip : "h1"
      html_cls  = args[2] ? args[2].strip : ""
      raw "<#{html_tag} class=#{html_cls}>#{text}</#{html_tag}>".html_safe
    end
  end
end
