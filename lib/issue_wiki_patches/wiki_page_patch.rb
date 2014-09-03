module IssueWikiPatches
  module WikiPagePatch
    
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        belongs_to  :issue
        has_many    :issue_wiki_vote, :as => :votable, :dependent => :delete_all
        has_many    :comments, :as => :commented, :dependent => :delete_all, :order => "created_on"
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def get_issue_wiki_sections
        if text && (text.chomp.include?("{{iwsection(") || text.chomp.include?("{{usersection"))
          section_array = parse_section_text(text)
        else
          section_array = ["{{iwtabs}}"]
          project.issue_wiki_sections.each do |iws|
            section_array << [ "{{iwsection(#{iws.id})}}", "" ]
          end
          section_array << [ "{{usersection(User Section,h1)}}", text ] if text && !text.blank?
        end
        section_array
      end

      def parse_section_text(input_text)
        parsed_section_array = input_text.chomp.split(/\r\n|\n/).inject([]) do |a, v|
          if v =~ /{{iw.*}}|{{user.*}}/
            a << [v.gsub(/^{{|}}$/, ""), []]
          elsif v =~ /{{endiw.*}}/
          else
            a.last[1] << v
          end
          a
        end.select{ |k, v| (k.start_with?("iwsection") || k.start_with?("usersection") || k.start_with?("iwtabs") )}.map{ |k, v| ["{{#{k}}}", v.join("\n")] }
        parsed_section_array
      end

      def resort_iw_sections(input_text)
        if input_text && input_text.chomp.include?("{{usersection")
          section_array = parse_section_text(input_text)
          ret_text = ""
          section_array.each do |k, v| 
            if (k.start_with?("{{iwsection") || k.start_with?("{{usersection") )
              ret_text << "#{k}\n#{v}\n#{k.gsub("iwsection","endiwsection").gsub("usersection","endiwsection")}\n"
            else
              ret_text << "#{k}\n#{v}\n"
            end
          end
          return ret_text
        else
          return input_text
        end
      end

      def total_iw_vote_up
        self.issue_wiki_vote.sum(:value, :conditions => 'value > 0')
      end

      def total_iw_vote_down
        self.issue_wiki_vote.sum(:value, :conditions => 'value < 0')
      end

      def total_iw_vote
        self.issue_wiki_vote.sum(:value)
      end

      def commentable?(user=User.current)
        user.allowed_to?(:add_issue_wiki_comments, project)
      end
    end
  end
end
