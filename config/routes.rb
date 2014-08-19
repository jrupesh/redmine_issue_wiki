match 'issues/:id/showissuewiki',:to => 'issue_wiki#show_issue_wiki',   :as => 'show_issue_wiki',   :via => :get
match 'issues/:id/editissuewiki',  :to => 'issue_wiki#edit_issue_wiki', :as => 'issue_wiki',        :via => [:get, :post, :put]
match 'issues/:id/updateissuewiki',:to => 'issue_wiki#update_issue_wiki', :as => 'update_issue_wiki', :via => [:post, :put]
match 'issues/:id/previewissuewiki',:to => 'issue_wiki#preview', :as => 'issue_wiki_preview', :via => :put
match 'issues/:id/issuewikiaddattachment',:to => 'issue_wiki#add_attachment', :as => 'add_attachment_issue_wiki', :via => [:post]
match 'issues/:id/protectissuewiki',:to => 'issue_wiki#protect', :as => 'issue_wiki_protect', :via => :post
match 'issues/:id/renameissuewiki',:to => 'issue_wiki#rename', :as => 'rename_issue_wiki', :via => [:get, :post]
match 'issues/:id/destroyissuewiki',:to => 'issue_wiki#destroy', :as => 'destroy_issue_wiki', :via => :delete

match 'issues/:issue_id/wiki/edit/:id',:to => 'wiki#edit', :via => :get
match 'issues/:issue_id/wiki/history/:id',:to => 'wiki#history', :via => :get

resources :issue_wiki_sections
match 'projects/:project_id/issue_wiki_section/:id', :to => 'issue_wiki_sections#update', :via => [:put, :post], :as => 'update_issue_wiki_section'