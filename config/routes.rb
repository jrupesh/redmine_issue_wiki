match 'issues/:id/showissuewiki',:to => 'issue_wiki#show_issue_wiki',   :as => 'show_issue_wiki',   :via => :get
match 'issues/:id/editissuewiki',  :to => 'issue_wiki#edit_issue_wiki', :as => 'issue_wiki',        :via => [:get, :post, :put]
match 'issues/:id/updateissuewiki',:to => 'issue_wiki#update_issue_wiki', :as => 'update_issue_wiki', :via => [:post, :put]
match 'issues/:id/preview',:to => 'issue_wiki#preview', :as => 'issue_wiki_preview', :via => [:get]
match 'issues/:id/add_attachment',:to => 'issue_wiki#add_attachment', :as => 'add_attachment_issue_wiki', :via => [:post]

resources :issue_wiki_sections
match 'projects/:project_id/issue_wiki_section/:id', :to => 'issue_wiki_sections#update', :via => [:put, :post], :as => 'update_issue_wiki_section'