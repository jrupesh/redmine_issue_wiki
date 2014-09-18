match 'issues/:id/showissuewiki',:to => 'issue_wiki#show_issue_wiki',   :as => 'show_issue_wiki',   :via => :get
match 'issues/:id/editissuewiki',  :to => 'issue_wiki#edit_issue_wiki', :as => 'issue_wiki',        :via => [:get, :post, :put]
match 'issues/:id/master_edit_issue_wiki',  :to => 'issue_wiki#master_edit_issue_wiki', :as => 'master_edit_issue_wiki', :via => :get
match 'issues/:id/updateissuewiki',:to => 'issue_wiki#update_issue_wiki', :as => 'update_issue_wiki', :via => [:post, :put]
match 'issues/:id/previewissuewiki',:to => 'issue_wiki#preview', :as => 'issue_wiki_preview', :via => :put
match 'issues/:id/issuewikiaddattachment',:to => 'issue_wiki#add_attachment', :as => 'add_attachment_issue_wiki', :via => [:post]
match 'issues/:id/protectissuewiki',:to => 'issue_wiki#protect', :as => 'issue_wiki_protect', :via => :post
match 'issues/:id/renameissuewiki',:to => 'issue_wiki#rename', :as => 'rename_issue_wiki', :via => [:get, :post]
match 'issues/:id/destroyissuewiki',:to => 'issue_wiki#destroy', :as => 'destroy_issue_wiki', :via => :delete

match 'issues/:id/wikicomments/:section_id',:to => 'issue_wiki#comments', :as => 'issue_wiki_comments', :via => :get

match 'issues/:id/voteissuewiki',:to => 'issue_wiki#vote', :as => 'issue_wiki_votes', :via => :post

match 'issues/:issue_id/wiki/edit/:id',:to => 'wiki#edit', :via => :get
match 'issues/:issue_id/wiki/history/:id',:to => 'wiki#history', :via => :get

match 'issues/:id/wiki/:wiki_id/comments/:section_id',:to => 'issue_wiki_comments#new', :as => "issue_wiki_comments_new", :via => :get
match 'issues/:id/wiki/:wiki_id/comments/:section_id',:to => 'issue_wiki_comments#create', :as => "issue_wiki_comments_create", :via => :post
match 'issue_wiki_comments/:id',:to => 'issue_wiki_comments#edit', :as => "issue_wiki_comments_edit", :via => :get
match 'issue_wiki_comments/:id',:to => 'issue_wiki_comments#update', :as => "issue_wiki_comments_update", :via => [ :put, :post ]
match 'projects/:project_id/issue_wiki_section/:id', :to => 'issue_wiki_sections#update', :via => [:put, :post], :as => 'update_issue_wiki_section'
resources :issue_wiki_comments
resources :issue_wiki_sections
