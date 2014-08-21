require 'spec_helper'

describe Api::V0::ImportsController, :type => :controller do
  def valid_attributes
    {
      import: { upload: fixture_file_upload('/belgrano_productos.csv', 'text/csv'),
                padma_id: 'belgrano',
                object: 'Product'
      },
      app_key: ENV['app_key']
    }
  end


  describe "#show" do
    before do
      i = FactoryGirl.create(:product_import, :upload => fixture_file_upload('/belgrano_productos.csv', 'text/csv'))
      @import_id = i.id
    end

    it "requires a valid app_key" do
      get :show, id: @import_id
      should respond_with 401
    end

    describe "with a valid id" do
      before do
        get :show, id: @import_id,
            app_key: ENV['app_key']
      end
      let(:json){ActiveSupport::JSON.decode(response.body)}
      it { should respond_with 200 }
      it "returns json with import status" do
        json['status'].should == 'ready'
      end
      it "returns json with failed_rows count" do
        json['failed_rows'].should == 0
      end
      it "returns json with imported_ids count" do
        json['imported_ids'].should == 0
      end
    end
  end

  describe "with an existing business" do
    before do
      unless @belgrano = Business.find_by_name('belgrano')
        @belgrano = FactoryGirl.create(:business, name: 'Belgrano', padma_id: 'belgrano')
      end
    end

    describe "#create" do

      it "queues import in delayed_job" do
        expect{
          post :create, valid_attributes
        }.to change{Delayed::Job.count}.by 1
      end
    end
  end

  describe "whithout an existing business" do
    describe "#create" do
      it "creates a new business" do
        expect{
          post :create, valid_attributes
        }.to change{Business.count}.by 1
      end
    end
  end
end
