module LinkedinApi
  include ActiveSupport::Concern

  #http://developer.linkedin.com/documents/profile-api
  URL = "https://api.linkedin.com/v1"
  #http://developer.linkedin.com/documents/profile-fields
  PROFILE_FIELDS = %w(summary positions languages num-connections industry
    skills certifications educations num-recommenders interests email-address)
  DEFAULT_HEADERS = {
    'x-li-format' => 'json'
  }

  private

  def raise_errors(response)
    # Even if the json answer contains the HTTP status code, LinkedIn also sets this code
    # in the HTTP answer (thankfully).
    case response.code.to_i
    when 401
      data = JSON.parse(response.body)
      raise LinkedIn::Errors::UnauthorizedError.new(data), "(#{data.status}): #{data.message}"
    when 400
      data = JSON.parse(response.body)
      raise LinkedIn::Errors::GeneralError.new(data), "(#{data.status}): #{data.message}"
    when 403
      data = JSON.parse(response.body)
      raise LinkedIn::Errors::AccessDeniedError.new(data), "(#{data.status}): #{data.message}"
    when 404
      raise LinkedIn::Errors::NotFoundError, "(#{response.code}): #{response.message}"
    when 500
      raise LinkedIn::Errors::InformLinkedInError, "LinkedIn had an internal error. Please let them know in the forum. (#{response.code}): #{response.message}"
    when 502..503
      raise LinkedIn::Errors::UnavailableError, "(#{response.code}): #{response.message}"
    end
  end

  def get(path, options={})
    response = HTTParty.get("#{URL}#{path}", DEFAULT_HEADERS.merge(options))
    raise_errors(response)
    response.body
  end

  def simple_query(path, options={})
    fields = options.delete(:fields) || PROFILE_FIELDS

    if options.delete(:public)
      path +=":public"
    elsif fields
      path +=":(#{fields.map{ |f| f.to_s.gsub("_","-") }.join(',')})"
    end

    headers = options.delete(:headers) || {}
    params  = to_query(options)
    path   += "?#{params}" if !params.empty?

    options[:format] == 'json' ? JSON.parse(get(path, headers)) : get(path, headers)
  end

  def person_path(options)
    path = "/people/"
    if id = options.delete(:id)
      path += "id=#{id}"
    elsif url = options.delete(:url)
      path += "url=#{CGI.escape(url)}"
    else
      path += "~"
    end
  end

  def to_query(params)
    params.map { |k, v|
      if v.class == Array
        to_query(v.map { |x| [k, x] })
      else
        v.nil? ? escape(k) : "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
      end
    }.join("&")
  end

end
