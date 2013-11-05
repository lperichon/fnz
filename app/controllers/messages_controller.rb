class MessagesController < ApplicationController
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
    if params[:secret_key] == Messaging::API_SECRET
      MessageProcessor.catch_message(params[:key_name],ActiveSupport::JSON.decode(params[:data]).symbolize_keys)
      render text: 'received', status: 200
    else
      render text: 'wrong secret_key', status: 403
    end
  end

end
