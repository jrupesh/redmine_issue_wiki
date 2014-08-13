require 'redmine'

Redmine::Plugin.register :redmine_issue_wiki do
  name 'Redmine Issue Wiki'
  author 'Rupesh J'
  description 'This plugin provide wiki as a tab representation in a Issue.'
  version '1.0.0'
  requires_redmine :version_or_higher => '2.5'

  project_module :wiki do
    permission :wiki_issue, { :issue_wiki => [ :show_issue_wiki ] }, :require => :member
    permission :edit_issue_wiki_pages, { :issue_wiki => [ :show_issue_wiki, :edit_issue_wiki ] }, :require => :member
  end
end