class AddColIssueToWikiPages < ActiveRecord::Migration
  def change
    add_column :wiki_pages, :issue_id, :integer
    add_column :wiki_pages, :comments_count, :integer
    add_index  :wiki_pages, [:issue_id ], :unique => true, :name => :issues_ids
  end
end
