module IssueWikiPatches
  module IssuePatch
    
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        has_one :wiki_page
      end
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end
