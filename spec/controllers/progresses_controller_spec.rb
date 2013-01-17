require 'spec_helper'

describe ProgressesController do
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

class ProgressesControllerTest < ActionController::TestCase
  setup do
    @progress = Progress.first!
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:progresses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create progress" do
    assert_difference('Progress.count') do
      post :create, progress: { activity: @progress.activity, bit_map: @progress.bit_map }
    end

    assert_redirected_to progress_path(assigns(:progress))
  end

  test "should show progress" do
    get :show, id: @progress
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @progress
    assert_response :success
  end

  test "should update progress" do
    put :update, id: @progress, progress: { activity: @progress.activity, bit_map: @progress.bit_map }
    assert_redirected_to progress_path(assigns(:progress))
  end

  test "should destroy progress" do
    assert_difference('Progress.count', -1) do
      delete :destroy, id: @progress
    end

    assert_redirected_to progresses_path
  end
end
=end