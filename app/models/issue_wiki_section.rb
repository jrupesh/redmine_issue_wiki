class IssueWikiSection < ActiveRecord::Base
  unloadable
  
  store         :format_store, accessors: [ :wikiformat, :owner_role, :section_group, :tool_tip ]

  belongs_to  :project
  belongs_to  :user

  acts_as_list
  
  validates_presence_of :heading, :project
  validates_format_of :heading, :with => /\A[^,\.\/\?\;\|\:]*\z/

  scope :sorted, lambda { order("#{table_name}.position ASC") }

  AVAILABLE_FORMATS = [ "H1", "H2", "H3" ].freeze

  def <=>(issuewikisection)
    position <=> issuewikisection.position
  end

end