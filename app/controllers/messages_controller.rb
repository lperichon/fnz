class MessagesController < ApplicationController
  include SnsHelper
  include SsoSessionsHelper
  
  def sns
    case sns_type
    when 'SubscriptionConfirmation'
      # confirm subscription to Topic
      render json: Typhoeus.get(sns_data[:SubscribeURL]).body, status: 200
    when 'Notification'
      if sns_verified?
        unless sns_duplicate_submission?
          MessageProcessor.catch_message(sns_topic,sns_message)
          sns_set_as_received!
          render json: "received", status: 200
        else
          render json: 'duplicate', status: 200
        end
      else
        render json: 'unverified', status: 403
      end
    else
      render json: 'WTF', status: 400
    end
  end  
  
  ##
  #
  # Valid Key Names: subcription_change, trial_lesson, birthday @see Trigger::VALID_EVENT_NAMES
  # Global Key Names: birthday @see Trigger::GLOBAL_EVENTS
  #
  # data MUST include :account_name key EXCEPT for Global Key Names.
  #
  # @argument key_name [String]
  # @argument data [String] JSON encoded
  # @argument secret_key [String]
  def catch_message
    Rails.logger.debug "Entering messages controller"
    if params[:secret_key] == Messaging::API_SECRET
      Rails.logger.debug "Secret key OK, catching message"
      MessageProcessor.catch_message(params[:key_name],ActiveSupport::JSON.decode(params[:data]).symbolize_keys)
      render text: 'received', status: 200
    else
      render text: 'wrong secret_key', status: 403
    end
  end

end
