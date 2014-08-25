class CreateIssueWikiVotes < ActiveRecord::Migration
  def change
    create_table :issue_wiki_votes do |t|
      t.string      :votable_type, :limit => 30, :default => "", :null => false
      t.integer     :votable_id, :default => 0, :null => false
      t.belongs_to  :user, :default => 0, :null => false
      t.belongs_to  :issue_wiki_section, :default => nil
      t.integer     :value
      t.string      :vote_key, :default => nil
      t.timestamps
    end
    add_index  :issue_wiki_votes, [:vote_key ], :name => :key_str_votes
    add_index  :issue_wiki_votes, [:votable_type, :votable_id ], :name => :votable_id_type
    add_index  :issue_wiki_votes, [:votable_type, :votable_id, :issue_wiki_section_id ], :name => :votable_id_type_section
  end
end
