require 'rails_helper'

RSpec.describe "Volunteers", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/volunteers/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/volunteers/create"
      expect(response).to have_http_status(:success)
    end
  end

end
