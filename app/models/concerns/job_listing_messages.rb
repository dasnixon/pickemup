module JobListingMessages
  extend ActiveSupport::Concern

  def send_message(recipients, msg_body, subject, job_listing_id = nil, sanitize_text = true, attachment = nil, message_timestamp = Time.now)
    convo = Conversation.new({subject: subject})
    convo.job_listing_id = job_listing_id
    convo.created_at = message_timestamp
    convo.updated_at = message_timestamp
    message = messages.new({:body => msg_body, :subject => subject, :attachment => attachment})
    message.created_at = message_timestamp
    message.updated_at = message_timestamp
    message.conversation = convo
    message.recipients = recipients.is_a?(Array) ? recipients : [recipients]
    message.recipients = message.recipients.uniq
    return message.deliver false,sanitize_text
  end
end
