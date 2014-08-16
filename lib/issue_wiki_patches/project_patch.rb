module IssueWikiPatches
  module ProjectPatch
    
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        has_many :issue_wiki_sections, :dependent => :delete_all
      end
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end

Project.send(:include, IssueWikiPatches::ProjectPatch)