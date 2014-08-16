class CreateIssueWikiSections < ActiveRecord::Migration
  def change
    create_table :issue_wiki_sections do |t|
      t.belongs_to  :project
      t.belongs_to  :user
      t.text        :heading
      t.integer     :position,      :default => 1
      t.text        :format_store
      t.timestamps
    end

    add_index(:issue_wiki_sections, :position)
  end
end