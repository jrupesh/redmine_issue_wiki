require 'redmine'
require 'wiki_macros'

Rails.configuration.to_prepare do

  require_dependency 'issue_wiki_hooks/layout_hooks'

  unless Project.included_modules.include? IssueWikiPatches::ProjectPatch
    Project.send(:include, IssueWikiPatches::ProjectPatch)
  end

  unless WikiController.included_modules.include? IssueWikiPatches::WikiControllerPatch
    WikiController.send(:include, IssueWikiPatches::WikiControllerPatch)
  end

  unless Issue.included_modules.include? IssueWikiPatches::IssuePatch
    Issue.send(:include, IssueWikiPatches::IssuePatch)
  end

  unless WikiPage.included_modules.include? IssueWikiPatches::WikiPagePatch
    WikiPage.send(:include, IssueWikiPatches::WikiPagePatch)
  end

  unless User.included_modules.include? IssueWikiPatches::UserPatch
    User.send(:include, IssueWikiPatches::UserPatch)
  end

  unless Comment.included_modules.include? IssueWikiPatches::CommentPatch
    Comment.send(:include, IssueWikiPatches::CommentPatch)
  end

  unless ProjectsHelper.included_modules.include? IssueWikiPatches::ProjectsHelperPatch
    ProjectsHelper.send(:include, IssueWikiPatches::ProjectsHelperPatch)
  end

end

Redmine::Plugin.register :redmine_issue_wiki do
  name 'Redmine Issue Wiki'
  author 'Rupesh J'
  description 'This plugin provide wiki as a tab representation in a Issue.'
  version '0.1'
  requires_redmine :version_or_higher => '2.5'

  project_module :wiki do
    permission :vote_issue_wiki,          {},                                  :require => :member
    permission :view_issue_wiki_comments, {},                                  :require => :member
    permission :delete_issue_wiki_comments, { :issue_wiki_comments => :destroy },
                                                                               :require => :member
    permission :add_issue_wiki_comments,  { :issue_wiki_comments => [:create, :edit, :new,
     :update ] },                                                              :require => :member
  end

  project_module :wiki_templates do
    permission :manage_issue_wiki_sections, { :issue_wiki_sections => 
      [ :index, :create, :update, :destroy ] },                                :require => :member
    permission :master_edit_issue_wiki,   { :issue_wiki => :master_edit_issue_wiki },
                                                                               :require => :member
  end

  # project_module :quality_tree do

  # end

  settings :default => {
    'iw_section_group'    => "",
    'issue_wiki_tracker'  => "" 
    }, :partial => 'settings/issue_wiki_section_settings'
end