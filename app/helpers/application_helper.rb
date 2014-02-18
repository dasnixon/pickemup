module ApplicationHelper
  ALERT_TYPES = [:danger, :info, :success, :warning]

  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      next if message.blank?

      type = :success if type == :notice
      type = :danger  if type == :alert || type == :error
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                           content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                           "<strong>#{msg}</strong>".html_safe, :class => "message_notification alert alert-#{type}")
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end

  def score_class(score)
    case score.to_i
    when 0..24
      'poor-score-color'
    when 25..49
      'low-score-color'
    when 50..74
      'medium-score-color'
    else
      'high-score-color'
    end
  end

  def find_interview(conversation)
    job_listing_id, user_id, company_id = conversation.job_listing_id, nil, nil
    conversation.participants.each do |p|
      p.is_a?(User) ? user_id = p.id : company_id = p.id
    end
    Interview.find_by(job_listing_id: job_listing_id, user_id: user_id, company_id: company_id)
  end
end
