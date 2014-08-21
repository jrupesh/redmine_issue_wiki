module IssueWikiHooks
  class LayoutHooks < Redmine::Hook::ViewListener
  
    def view_layouts_base_html_head(context = { })
      o = "".html_safe
      o << javascript_include_tag('issue_wiki_tabs.js', :plugin => :redmine_issue_wiki)
      o << stylesheet_link_tag('issue_wiki_tabs.css'  , :plugin => :redmine_issue_wiki)
      return o
    end
  end
end
