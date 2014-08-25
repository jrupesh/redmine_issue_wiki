class IssueWikiVote < ActiveRecord::Base
  unloadable

  belongs_to :votable, :polymorphic => true
  belongs_to :user
  belongs_to :issue_wiki_section

  validates_inclusion_of :value, in: [1, -1]
  validates_uniqueness_of :value, :scope => [:issue_wiki_section_id,
    :votable_type, :votable_id, :user_id] if :unique_issue_wikipage_vote?

  after_initialize :update_user_weight

  def update_user_weight
    self.user = User.current
    self.weight = 0.0 if self.weight.nil?
  end

  def unique_issue_wikipage_vote?
    return false if votable_type != "WikiPage" || !vote_key.nil?
    true
  end
end