class IssueWikiController < ApplicationController
  unloadable
  before_filter :find_wiki, :authorize
  before_filter :find_existing_or_new_page, :only => [:show_issue_wiki]

  helper :attachments
  include AttachmentsHelper
  helper :watchers
  
  helper :wiki
  include WikiHelper

  def show_issue_wiki
    logger.debug("IssueWikiController : show_issue_wiki")
    if params[:version] && !User.current.allowed_to?(:view_wiki_edits, @project)
      deny_access
      return
    end
    @content = @page.content_for_version(params[:version])
    if @content.nil?
      if User.current.allowed_to?(:edit_issue_wiki_pages, @project) && editable? && !api_request?
        edit_issue_wiki
        render :action => 'edit_issue_wiki'
      else
        render_404
      end
      return
    end

    @editable = editable?
    @sections_editable = @editable && User.current.allowed_to?(:edit_issue_wiki_pages, @page.project) &&
      @content.current_version? && Redmine::WikiFormatting.supports_section_edit?

    respond_to do |format|
      format.html
      format.api
    end    
  end

  def edit_issue_wiki
    logger.debug("IssueWikiController : edit_issue_wiki")
    return render_403 unless editable?
    if @page.new_record?
      if params[:parent].present?
        @page.parent = @page.wiki.find_page(params[:parent].to_s)
      end
    end

    @content = @page.content_for_version(params[:version])
    @content ||= WikiContent.new(:page => @page)
    @content.text = initial_page_content(@page) if @content.text.blank?
    # don't keep previous comment
    @content.comments = nil

    # To prevent StaleObjectError exception when reverting to a previous version
    @content.version = @page.content.version if @page.content

    @text = @content.text
    if params[:section].present? && Redmine::WikiFormatting.supports_section_edit?
      @section = params[:section].to_i
      @text, @section_hash = Redmine::WikiFormatting.formatter.new(@text).get_section(@section)
      render_404 if @text.blank?
    end
  end

  # Creates a new page or updates an existing one
  def update_issue_wiki
    return render_403 unless editable?
    was_new_page = @page.new_record?
    @page.safe_attributes = params[:wiki_page]

    @content = @page.content || WikiContent.new(:page => @page)
    content_params = params[:content]
    if content_params.nil? && params[:wiki_page].is_a?(Hash)
      content_params = params[:wiki_page].slice(:text, :comments, :version)
    end
    content_params ||= {}

    @content.comments = content_params[:comments]
    @text = content_params[:text]
    if params[:section].present? && Redmine::WikiFormatting.supports_section_edit?
      @section = params[:section].to_i
      @section_hash = params[:section_hash]
      @content.text = Redmine::WikiFormatting.formatter.new(@content.text).update_section(@section, @text, @section_hash)
    else
      @content.version = content_params[:version] if content_params[:version]
      @content.text = @text
    end
    @content.author = User.current

    if @page.save_with_content(@content)
      attachments = Attachment.attach_files(@page, params[:attachments])
      render_attachment_warning_if_needed(@page)
      call_hook(:controller_wiki_edit_after_save, { :params => params, :page => @page})

      respond_to do |format|
        format.html {
          anchor = @section ? "section-#{@section}" : nil
          redirect_to project_wiki_page_path(@project, @page.title, :anchor => anchor)
        }
        format.api {
          if was_new_page
            render :action => 'show', :status => :created, :location => project_wiki_page_path(@project, @page.title)
          else
            render_api_ok
          end
        }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.api { render_validation_errors(@content) }
      end
    end

  rescue ActiveRecord::StaleObjectError, Redmine::WikiFormatting::StaleSectionError
    # Optimistic locking exception
    respond_to do |format|
      format.html {
        flash.now[:error] = l(:notice_locking_conflict)
        render :action => 'edit'
      }
      format.api { render_api_head :conflict }
    end
  rescue ActiveRecord::RecordNotSaved
    respond_to do |format|
      format.html { render :action => 'edit' }
      format.api { render_validation_errors(@content) }
    end
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