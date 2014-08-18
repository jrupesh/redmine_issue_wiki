require_dependency 'wiki_controller'
module IssueWikiPatches
  module WikiControllerPatch
    
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
      end
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end

