require 'rails_helper'

RSpec.describe "Summaries", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/summary/show"
      expect(response).to have_http_status(:success)
    end
  end

end
