require_dependency 'wiki_controller'
module IssueWikiPatches
  module WikiControllerPatch
    
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        before_filter :issue_wiki_edit, only: :edit
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def issue_wiki_edit
        find_existing_or_new_page
        if !@page.issue.nil?
          redirect_to issue_wiki_path(@page.issue)
        end
      end
    end
  end
end

