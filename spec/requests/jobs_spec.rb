require 'rails_helper'

RSpec.describe "Jobs", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/jobs/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/jobs/create"
      expect(response).to have_http_status(:success)
    end
  end

end
