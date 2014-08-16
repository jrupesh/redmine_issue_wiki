module IssueWikiHelper
  def edit_issue_wiki_sections(text)
    text_area_tag 'content[text]', text, :cols => 100, :rows => 10,
                  :class => 'wiki-edit', :accesskey => accesskey(:edit) 
  end
end