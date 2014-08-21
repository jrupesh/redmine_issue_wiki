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
      def get_issue_wiki_sections
        if text && (text.chomp.include?("{{iwsection(") || text.chomp.include?("{{usersection"))
          section_array = text.chomp.split(/\r\n|\n/).inject([]) do |a, v|
            if v =~ /{{iw.*}}|{{user.*}}/
              a << [v.gsub(/^{{|}}$/, ""), []]
            elsif v =~ /{{endiw.*}}/
            else
              a.last[1] << v
            end
            a
          end.select{ |k, v| (k.start_with?("iwsection") || k.start_with?("usersection") || k.start_with?("iwtabs") )}.map{ |k, v| ["{{#{k}}}", v.join("\n")] }
        else
          section_array = ["{{iwtabs}}"]
          project.issue_wiki_sections.each do |iws|
            section_array << [ "{{iwsection(#{iws.id})}}", "" ]
          end
          section_array << [ "{{usersection(User Section,h1)}}", text ] if text && !text.blank?
        end
        section_array
      end
    end
  end
end
