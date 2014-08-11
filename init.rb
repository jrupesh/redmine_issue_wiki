require 'redmine'
require 'redmine_issue_wiki_listener.rb'

Redmine::Plugin.register :redmine_issue_wiki do
  name 'Redmine Issue Wiki'
  author 'Rupesh J'
  description 'This plugin provide wiki as a tab representation in a Issue.'
  version '1.0.0'
  requires_redmine :version_or_higher => '2.5'
end