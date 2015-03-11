require 'spec_helper'

RSpec.describe Api::V0::MergesController, :type => :controller do

  describe "POST /api/v0/merges" do
    before do
      post :create,
           app_key: Api::V0::ApiController::APP_KEY,
           merge: {
             father_id: 'father-id',
             son_id: 'son-id'
           }
    end

    it { should respond_with 200 }

  end
end
