class IssueWikiVote < ActiveRecord::Base
  unloadable

  belongs_to :votable, :polymorphic => true
  belongs_to :user
  belongs_to :issue_wiki_section

  validates_inclusion_of :value, in: [1, -1]
  validates_uniqueness_of :value, :scope => [:issue_wiki_section_id,
    :votable_type, :votable_id, :user_id] if :unique_issue_wikipage_vote?

  before_save :update_user

  def update_user
    self.user = User.current 
  end

  def unique_issue_wikipage_vote?
    return false if votable_type != "WikiPage" || !vote_key.nil?
    true
  end
end