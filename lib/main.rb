require "sinatra"
$:.unshift(File.expand_path("../../lib", __FILE__))

require "deciders/ci"
require "deciders/pingdom"
require "final_decider"
require "input_validator"

ci = Decider::CI.new
pingdom = Decider::Pingdom.new(
  ENV["PINGDOM_APP_KEY"],
  ENV["PINGDOM_USERNAME"],
  ENV["PINGDOM_PASSWORD"],
  ENV["PINGDOM_HOSTNAME"]
)

final_decider = FinalDecider.new([ci, pingdom])

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

get "/" do
  erb :main, :locals => { can_i_bump: final_decider.can_i_bump?, reasons: final_decider.reasons, build_number: ci.build_number }
end
