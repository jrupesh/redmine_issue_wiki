module IssueWikiPatches
  module ProjectsHelperPatch
    
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        alias_method_chain :project_settings_tabs, :iw
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def project_settings_tabs_with_iw
        tabs = project_settings_tabs_without_iw

        project_iws_action = {:name => 'issue_wiki_sections', :controller => :issue_wiki_sections,
          :action => :index, :partial => 'projects/settings/issue_wiki_sections', 
          :label => :label_iws}

        tabs.push ( project_iws_action )     if User.current.allowed_to?(project_iws_action,
         @project)
        tabs
      end
    end
  end
end
