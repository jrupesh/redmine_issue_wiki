require 'redmine'
require 'issue_wiki_patches/project_patch'
require 'issue_wiki_patches/wiki_controller_patch'

Rails.configuration.to_prepare do
  unless Project.included_modules.include? IssueWikiPatches::ProjectPatch
    Project.send(:include, IssueWikiPatches::ProjectPatch)
  end

  unless WikiController.included_modules.include? IssueWikiPatches::WikiControllerPatch
    WikiController.send(:include, IssueWikiPatches::WikiControllerPatch)
  end
end

Redmine::Plugin.register :redmine_issue_wiki do
  name 'Redmine Issue Wiki'
  author 'Rupesh J'
  description 'This plugin provide wiki as a tab representation in a Issue.'
  version '1.0.0'
  requires_redmine :version_or_higher => '2.5'

  project_module :wiki do
    permission :wiki_issue,             { :issue_wiki => [ :show_issue_wiki ] }, :require => :member
    permission :view_issue_wiki_edits,  { :issue_wiki => [ :show_issue_wiki ] }, :require => :member
    permission :edit_issue_wiki_pages,  { :issue_wiki => [ :show_issue_wiki, :edit_issue_wiki,
     :update_issue_wiki ] }, :require => :member

    permission :manage_issue_wiki_sections, { :issue_wiki_sections => 
      [ :index, :create, :update, :destroy ] }, :require => :member
  end
end