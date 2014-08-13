class IssueWikiController < ApplicationController
  unloadable
  before_filter :find_wiki, :authorize
  # before_filter :find_existing_or_new_page, :only => [:show_issue_wiki]

  def show_issue_wiki
    logger.debug("IssueWikiController : show_issue_wiki")
    # if params[:version] && !User.current.allowed_to?(:view_wiki_edits, @project)
    #   deny_access
    #   return
    # end
    # @content = @page.content_for_version(params[:version])
    # if @content.nil?
    #   if User.current.allowed_to?(:edit_wiki_pages, @project) && editable? && !api_request?
    #     edit_issue_wiki
    #     render :action => 'edit_issue_wiki'
    #   else
    #     render_404
    #   end
    #   return
    # end
  end

private
  def find_wiki
    @issue = Issue.find(params[:id])
    @project = @issue.project
    @wiki = @project.wiki
    render_404 unless @wiki
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Finds the requested page or a new page if it doesn't exist
  def find_existing_or_new_page
    @page = @wiki.find_or_new_page("WIKI-#{@issue.id}")
    if @wiki.page_found_with_redirect?
      redirect_to params.update(:id => @page.title)
    end
  end

  # Finds the requested page and returns a 404 error if it doesn't exist
  def find_existing_page
    @page = @wiki.find_page(params[:id])
    if @page.nil?
      render_404
      return
    end
    if @wiki.page_found_with_redirect?
      redirect_to params.update(:id => @page.title)
    end
  end

  # Returns true if the current user is allowed to edit the page, otherwise false
  def editable?(page = @page)
    page.editable_by?(User.current)
  end

  # Returns the default content of a new wiki page
  def initial_page_content(page)
    helper = Redmine::WikiFormatting.helper_for(Setting.text_formatting)
    extend helper unless self.instance_of?(helper)
    helper.instance_method(:initial_page_content).bind(self).call(page)
  end

  def load_pages_for_index
    @pages = @wiki.pages.with_updated_on.
                reorder("#{WikiPage.table_name}.title").
                includes(:wiki => :project).
                includes(:parent).
                all
  end
end