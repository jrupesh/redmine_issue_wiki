class IssueWikiSection < ActiveRecord::Base
  unloadable
  
  store         :format_store, accessors: [ :wikiformat, :owner_role, :section_group, :tool_tip,
                      :reviewer_roles, :review_opts ]

  belongs_to  :project
  belongs_to  :user

  acts_as_list

  before_save  :remove_blanks_reviewer_roles
  
  validates_presence_of :heading, :project
  validates_format_of :heading, :with => /\A[^,\.\/\?\;\|\:]*\z/

  scope :sorted, lambda { order("#{table_name}.position ASC") }

  AVAILABLE_FORMATS = [ "H1", "H2", "H3" ].freeze
  REVIEW_OPTIONS    = { "None" => 0, "All" => 1 , "Any" => 2  }.freeze

  def remove_blanks_reviewer_roles
    self.reviewer_roles.reject!{ |p| p.blank? }
  end

  def <=>(issuewikisection)
    position <=> issuewikisection.position
  end

  def section_value
    return 0 if self.review_opts.to_i == 0
    if self.reviewer_roles.any? { |x| User.current.roles_for_project(project).collect{|c| "#{c.id}"}.include?(x) }
      ret = (self.review_opts.to_i == 1) ? (1.0/self.reviewer_roles.length) : 1
    end
    return ret
  end
end