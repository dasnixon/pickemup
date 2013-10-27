class APILogger
  CREATE_FAIL_PATH = "#{Rails.root}/log/create_fail.log"
  UPDATE_FAIL_PATH = "#{Rails.root}/log/update_fail.log"

  def initialize(action)
    @log = Logger.new("#{self.class}::#{action}_FAIL_PATH".constantize)
  end

  def log(*args)
    @log << "/\n" + args.join(", ")
  end
end
