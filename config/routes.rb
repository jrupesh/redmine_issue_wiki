match 'issues/:id/showissuewiki',:to => 'issue_wiki#show_issue_wiki',   :as => 'show_issue_wiki',   :via => :get
match 'issues/:id/editissuewiki',  :to => 'issue_wiki#edit_issue_wiki', :as => 'issue_wiki',        :via => [:post, :put]
match 'issues/:id/updateissuewiki',:to => 'issue_wiki#update_issue_wiki', :as => 'update_issue_wiki', :via => [:post, :put]
