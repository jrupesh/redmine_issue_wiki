module IssueWikiPatches
  module CommentPatch
    
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        
        belongs_to  :issue_wiki_section
        acts_as_nested_set :dependent => :destroy
      end
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end
