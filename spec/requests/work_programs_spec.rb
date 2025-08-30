require 'rails_helper'

RSpec.describe "WorkPrograms", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/work_programs/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/work_programs/create"
      expect(response).to have_http_status(:success)
    end
  end

end
