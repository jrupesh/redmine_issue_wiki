class IssueWikiController < ApplicationController
  unloadable
  before_filter :find_wiki, :authorize
  before_filter :find_existing_or_new_page, :only => [:show_issue_wiki, :update_issue_wiki,
    :edit_issue_wiki, :master_edit_issue_wiki]
  before_filter :find_existing_page, :only => [:rename, :protect, :add_attachment, :destroy, :preview]
  before_filter :find_attachments, :only => [:preview]

  helper :attachments
  include AttachmentsHelper
  helper :watchers
  
  helper :wiki
  include WikiHelper

  helper :issue_wiki
  include IssueWikiHelper

  def show_issue_wiki
    if params[:version] && !User.current.allowed_to?(:view_issue_wiki_edits, @project)
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

    respond_to do |format|
      format.html { redirect_to project_wiki_page_path(@project, @page.title) }
      format.js { render :layout => false }
      format.api
    end    
  end

  def master_edit_issue_wiki
    @master_edit = true
    edit_issue_wiki
    render :action => 'edit_issue_wiki'
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
    @editable = editable?
    @text = content_params[:text] || (content_params[:sectiontext] && content_params[:sectiontext].join("\r\n"))

    if params[:section].present? && Redmine::WikiFormatting.supports_section_edit?
      @section = params[:section].to_i
      @section_hash = params[:section_hash]
      @content.text = Redmine::WikiFormatting.formatter.new(@content.text).update_section(@section, @text, @section_hash)
    else
      @content.version = content_params[:version] if content_params[:version]
      @content.text = @text
    end
    @content.author = User.current
    # @content.version_condition = false if !was_new_page 

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
            render :action => 'show_issue_wiki', :status => :created, :location => project_wiki_page_path(@project, @page.title)
          else
            render_api_ok
          end
        }
        format.js {
          render :action => 'show_issue_wiki'
        }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit_issue_wiki' }
        format.js { render :action => 'edit_issue_wiki' }
        format.api { render_validation_errors(@content) }
      end
    end

  rescue ActiveRecord::StaleObjectError, Redmine::WikiFormatting::StaleSectionError
    # Optimistic locking exception
    respond_to do |format|
      format.html {
        flash.now[:error] = l(:notice_locking_conflict)
        render :action => 'edit_issue_wiki'
      }
      format.api { render_api_head :conflict }
    end
  rescue ActiveRecord::RecordNotSaved
    respond_to do |format|
      format.html { render :action => 'edit_issue_wiki' }
      format.api { render_validation_errors(@content) }
    end
  end

  # rename a page
  def rename
    return render_403 unless editable?
    @page.redirect_existing_links = true
    # used to display the *original* title if some AR validation errors occur
    @original_title = @page.pretty_title
    if request.post? && @page.update_attributes(params[:wiki_page])

      @content = @page.content_for_version(params[:version])
      @editable = editable?

      flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html { redirect_to project_wiki_page_path(@project, @page.title) }
        format.js { render :action => 'show_issue_wiki' }
      end      
    else
      respond_to do |format|
        format.html
        format.js { render :layout => false }
      end
    end
  end

  def protect
    @page.update_attribute :protected, params[:protected]
    @content = @page.content_for_version(params[:version])
    @editable = editable?

    respond_to do |format|
      format.html { redirect_to project_wiki_page_path(@project, @page.title) }
      format.js { render :action => 'show_issue_wiki' }
    end    
  end

  # Removes a wiki page and its history
  # Children can be either set as root pages, removed or reassigned to another parent page
  def destroy
    return render_403 unless editable?

    @descendants_count = @page.descendants.size
    if @descendants_count > 0
      case params[:todo]
      when 'nullify'
        # Nothing to do
      when 'destroy'
        # Removes all its descendants
        @page.descendants.each(&:destroy)
      when 'reassign'
        # Reassign children to another parent page
        reassign_to = @wiki.pages.find_by_id(params[:reassign_to_id].to_i)
        return unless reassign_to
        @page.children.each do |child|
          child.update_attribute(:parent, reassign_to)
        end
      else
        @reassignable_to = @wiki.pages - @page.self_and_descendants
        # display the destroy form if it's a user request
        return unless api_request?
      end
    end
    @page.destroy
    respond_to do |format|
      format.html { redirect_to issue_path(@issue) }
      format.api { render_api_ok }
    end
  end

  def preview
    # page is nil when previewing a new page
    return render_403 unless @page.nil? || editable?
    if @page
      @attachments += @page.attachments
      @previewed = @page.content
    end
    @text = params[:content][:text] || (params[:content][:sectiontext] && params[:content][:sectiontext].join("\n"))
    render :partial => 'common/preview'
  end

  def add_attachment
    return render_403 unless editable?
    attachments = Attachment.attach_files(@page, params[:attachments])
    render_attachment_warning_if_needed(@page)
    redirect_to :action => 'show', :id => @page.title, :project_id => @project
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
    @page = @issue.wiki_page || WikiPage.new(:wiki => @wiki, :title => Wiki.titleize("WIKI-#{@issue.id}"), :issue => @issue)
    if @wiki.page_found_with_redirect?
      redirect_to params.update(:id => @page.title)
    end
  end

  # Finds the requested page and returns a 404 error if it doesn't exist
  def find_existing_page
    @page = @issue.wiki_page
    if @page.nil?
      render_404
      return
    end
    if @wiki.page_found_with_redirect?
      redirect_to params.update(:issue_wiki_id => @page.title)
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