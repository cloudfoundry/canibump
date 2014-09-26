require "spec_helper"
require "rest-client"

describe "Sinatra Application" do
  let(:original_environment) do
    {
      "PINGDOM_APP_KEY" => "app_key",
      "PINGDOM_USERNAME" => "username",
      "PINGDOM_PASSWORD" => "password",
      "PINGDOM_HOSTNAME" => "hostname"
    }
  end

  let(:environment) { original_environment }

  before do
    start_can_i_bump({ env: environment })
  end

  after do
    stop_can_i_bump
  end

  describe "GET /" do
    it "returns no by default" do
      response = make_get_request
      expect(response.body).to match /NO/
      expect(response.body).to match /no data yet/
    end

    context "when the value is set to no" do
      before do
        make_put_request("no?reason=idunno&buildnumber=123")
      end

      it "returns no and prints outs the reason" do
        response = make_get_request
        expect(response.body).to match /NO/
        expect(response.body).to match /idunno/
      end
    end
  end

  describe 'PUT /:value' do
    context "when the value is not yes or no" do
      it "should fail" do
        expect { make_put_request("lala") }.to raise_error do |e|
          expect(e).to be_a RestClient::InternalServerError
          expect(e.response).to eq("Incorrect value")
        end
      end
    end

    context "when token is set in env variable" do
      let(:environment) { original_environment.merge("CAN_I_BUMP_TOKEN" => "app_token") }

      context "when the specified token does not match app token" do
        it "return Unauthorized" do
          expect{
            make_put_request("yes?token=request_token&buildnumber=123")
          }.to raise_error(RestClient::Unauthorized)
        end
      end

      context "when the specified token matches app token" do
       let(:environment) { original_environment.merge("CAN_I_BUMP_TOKEN" => "app_token") }

        context "when the buildnumber is provided" do
          it "returns 200" do
            response = make_put_request("yes?token=app_token&buildnumber=123")
            expect(response.code).to eq(200)
          end
        end

        context "when the buildnumber is not provided" do
          it "should fail" do
            expect { make_put_request("yes?token=app_token") }.to raise_error do |e|
              expect(e).to be_a RestClient::InternalServerError
              expect(e.response).to eq("Invalid buildnumber")
            end
          end
        end
      end
    end
  end
end
