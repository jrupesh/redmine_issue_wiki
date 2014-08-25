module IssueWikiPatches
  module UserPatch
    
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        has_many    :issue_wiki_vote, :as => :votable
      end
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end
