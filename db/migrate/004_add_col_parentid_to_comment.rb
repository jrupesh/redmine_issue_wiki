class AddColParentidToComment < ActiveRecord::Migration
  def change
    add_column :comments, :parent_id,   :integer
    add_column :comments, :lft,         :integer
    add_column :comments, :rgt,         :integer
    add_column :comments, :issue_wiki_section_id,  :integer, :default => nil
    Comment.rebuild!
  end
end
