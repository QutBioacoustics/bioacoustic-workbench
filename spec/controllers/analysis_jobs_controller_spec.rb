require 'spec_helper'

describe AnalysisJobsController do
  describe "GET #index" do
    it "populates a list"
    it "renders the list in json with the expected properties"
  end

  describe "GET #show" do
    it "assigns the requested item to the local variable"
    it "renders the item in json with the expected properties"
  end

  describe "GET #new" do
    it "assigns a new item to the local variable"
    it "renders the item in json with the expected properties"
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new item in the database"
      it "renders the new item in json with the expect properties, with status 201, with location header"
    end

    context "with invalid attributes" do
      it "does not save the new item in the database"
      it "renders the error in json with expected properties, with status 422"
    end
  end

  describe "PUT #update" do
    it 'exists in the database'

    context "with valid attributes" do
      it "updates the existing item in the database"
      it "returns with empty body and with status 200"
    end

    context "with invalid attributes" do
      it "does not update the existing item in the database"
      it "renders the error in json with expected properties, with status 422"
    end
  end

  describe "DELETE #destory" do
    it "finds the correct item fromthe database and assigns it to the local variable"
    it 'destories the correct item, and the database is updated'
    it "returns with empty body and with status 200"
  end
end

=begin
require 'test_helper'

class AnalysisJobsControllerTest < ActionController::TestCase
  setup do
    @analysis_job = AnalysisJob.first!
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:analysis_jobs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create analysis_job" do
    assert_difference('AnalysisJob.count') do
      post :create, analysis_job: { data_set_identifier: @analysis_job.data_set_identifier, description: @analysis_job.description, name: @analysis_job.name, notes: @analysis_job.notes, script_description: @analysis_job.script_description, script_display_name: @analysis_job.script_display_name, script_extra_data: @analysis_job.script_extra_data, script_name: @analysis_job.script_name, script_settings: @analysis_job.script_settings, script_version: @analysis_job.script_version }
    end

    assert_redirected_to analysis_job_path(assigns(:analysis_job))
  end

  test "should show analysis_job" do
    get :show, id: @analysis_job
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @analysis_job
    assert_response :success
  end

  test "should update analysis_job" do
    put :update, id: @analysis_job, analysis_job: { data_set_identifier: @analysis_job.data_set_identifier, description: @analysis_job.description, name: @analysis_job.name, notes: @analysis_job.notes, script_description: @analysis_job.script_description, script_display_name: @analysis_job.script_display_name, script_extra_data: @analysis_job.script_extra_data, script_name: @analysis_job.script_name, script_settings: @analysis_job.script_settings, script_version: @analysis_job.script_version }
    assert_redirected_to analysis_job_path(assigns(:analysis_job))
  end

  test "should destroy analysis_job" do
    assert_difference('AnalysisJob.count', -1) do
      delete :destroy, id: @analysis_job
    end

    assert_redirected_to analysis_jobs_path
  end
end
=end