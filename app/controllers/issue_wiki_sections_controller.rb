class IssueWikiSectionsController < ApplicationController
  unloadable
  before_filter :find_project_by_project_id, :authorize

  def index
  end

  def create
    @issuewikisections = IssueWikiSection.create(params[:issue_wiki_sections].merge(
      {:project => @project, :user => User.current }))
    @issuewikisections.save
    respond_to do |format|
      # format.html { redirect_to settings_project_path(:tab => 'issue_wiki_sections', :id => @project) }
      format.js
    end
  end

  def update
    @issuewikisections = IssueWikiSection.find(params[:id])
    update_hash = params[:issue_wiki_section] || params[:issue_wiki_sections]
    if @issuewikisections.update_attributes(update_hash.merge(
      { :user => User.current }))
      flash[:notice] = l(:notice_successful_update)
    end
    respond_to do |format|
      format.html { redirect_to settings_project_path(:tab => 'issue_wiki_sections', :id => @project) }
      format.js
    end
  end

  def destroy
    @id = params[:id]
    @issuewikisections = IssueWikiSection.find(@id)
    @issuewikisections.destroy
    respond_to do |format|
      # format.html { render 'index' }
      format.js
    end
  end
end
