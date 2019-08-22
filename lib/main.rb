require "sinatra"
$:.unshift(File.expand_path("../../lib", __FILE__))

require "json"
require "deciders/stateful"
require "final_decider"
require "input_validator"
require "mongo"

vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
client = Mongo::Client.new(vcap_services['mlab'][0]['credentials']['uri'], {retry_writes: false})

stateful_decider = Decider::Stateful.new(client)

final_decider = FinalDecider.new([stateful_decider])

set :protection, :except => :frame_options

put "/:value" do |value|
  if params["token"] != ENV["CAN_I_BUMP_TOKEN"]
    status 401
    return
  end


  begin
    ok_to_bump, buildnumber = InputValidator.new(value, params["buildnumber"]).values
  rescue InputValidator::IncorrectValue => e
    status 500
    body 'Incorrect value'
    return
  rescue InputValidator::InvalidBuildNumber
    status 500
    body 'Invalid buildnumber'
    return
  end

  stateful_decider.set_can_i_bump(ok_to_bump, params["reason"])
  status 200
end

get "/", :provides => 'html' do
  erb :main, :locals => { can_i_bump: final_decider.can_i_bump?, reasons: final_decider.reasons, build_number: stateful_decider.build_number }
end

get "/", :provides => 'json' do
  { can_i_bump: final_decider.can_i_bump? }.to_json
end
