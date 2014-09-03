class IssueWikiCommentsController < ApplicationController
  default_search_scope :wiki_pages
  
  before_filter :find_model_object
  before_filter :authorize

  helper :issue_wiki

  def new
    raise Unauthorized unless @page.commentable?
    render_404 if @page.nil?
    @section_id = params[:section_id] || ""
    @parent  = ""
    @parent  = Comment.find(params[:parent_id]) if params[:parent_id]
    # @div_id = "#{@section_id}"
    # @div_id += "-#{@parent_id}" if !@parent_id.blank?
    respond_to do |format|
      format.js { render :layout => false }
    end   
  end

  def create
    raise Unauthorized unless @page.commentable?
    if params[:comment] && params[:comment][:comments] && !params[:comment][:comments].blank?
      @section_id = params[:section_id]  || ""
      @parent_id  = params[:parent_id]  || ""
      @comment = @page.comments.build(:comments => params[:comment][:comments], :author => User.current,
          :issue_wiki_section_id => params[:section_id], :parent_id => @parent_id )
      @page.save

      # @div_id = "#{@section_id}"
      # @div_id += "-#{@parent_id}" if !@parent_id.blank?

    end
    respond_to do |format|
      format.js { render :layout => false }
    end    
  end

  def destroy
    @comment = @page.comments.find(params[:id])
    # @div_id = "#{@comment.issue_wiki_section_id}"
    # @div_id += "-#{@comment.parent_id}" if !@comment.parent_id.nil?

    @comment.destroy
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def edit
    raise Unauthorized unless @page.commentable?
    @comment = Comment.find(params[:id])
    render_404 if @comment.nil?
    # @div_id = "#{@comment.issue_wiki_section_id}"
    # @div_id += "-#{@comment.parent_id}" if !@comment.parent_id.nil?
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def update
    raise Unauthorized unless @page.commentable?
    @comment = Comment.find(params[:id])
    render_404 if @comment.nil?
    @comment.update_attributes(params[:comment])
    # @div_id = "#{@comment.issue_wiki_section_id}"
    # @div_id += "-#{@comment.parent_id}" if !@comment.parent_id.nil?
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  private

  def find_model_object
    if params.keys.include?("wiki_id")
      @object = WikiPage.find(params[:wiki_id])
      @project = @object.wiki.project if @object
    else
      @issue = Issue.find(params[:id])
      @object = @issue.wiki_page if @issue
      @project = @object.project if @object
    end
    @page = @object
    @comment = nil
    @page
  end
end
