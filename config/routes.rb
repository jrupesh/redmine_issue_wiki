match 'issues/:id/showissuewiki',:to => 'issue_wiki#show_issue_wiki', :as => 'show_issue_wiki',  :via => :get
# match 'issues/issuewiki',  :to => 'issue_wiki#show_issue_wiki',  :as => 'issue_wiki',  :via => [:post, :put]
