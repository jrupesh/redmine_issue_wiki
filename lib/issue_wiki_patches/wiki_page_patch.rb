module IssueWikiPatches
  module WikiPagePatch
    
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        belongs_to    :issue
      end
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end
