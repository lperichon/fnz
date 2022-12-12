require './config/boot'
require './config/environment'

require 'clockwork'
require 'active_support/time'

module Clockwork
  configure do
    #config[:logger] = Appsignal::Logger.new("clockwork") if ENV["APPSIGNAL_LOG"].present?
    config[:tz] = "America/Buenos_Aires"
    config[:thread] = true
  end
  handler do |job, time|
    puts "running #{job}, at #{time}"
    %x{ #{job} }
  end

  every(1.hour, "rake sync_with_padma_accounts")

  every(1.day, "rake create_monthly_installments", at: "01:00")
  every(1.day, "rake broadcast_end_of_memberships", at: "02:00")
  every(1.day, "rake create_recurrent_transactions", at: "03:00")
  every(1.day, "rake update_current_memberships", at: "04:00")
end
