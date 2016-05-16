require "sinatra"
$:.unshift(File.expand_path("../../lib", __FILE__))

require "json"
require "deciders/ci"
require "final_decider"
require "input_validator"

ci = Decider::CI.new

final_decider = FinalDecider.new([ci])

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

  ci.set_can_i_bump(ok_to_bump, params["reason"], buildnumber)
  status 200
end

get "/", :provides => 'html' do
  erb :main, :locals => { can_i_bump: final_decider.can_i_bump?, reasons: final_decider.reasons, build_number: ci.build_number }
end

get "/", :provides => 'json' do
  { can_i_bump: final_decider.can_i_bump? }.to_json
end
