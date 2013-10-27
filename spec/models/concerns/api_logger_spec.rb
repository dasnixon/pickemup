require 'spec_helper'

describe APILogger do
  let(:log_file) { "" }

  describe '#log' do
    it 'should save a comma-separated string to the log file' do
      Logger.should_receive(:new).and_return(log_file)
      new_logger = APILogger.new('CREATE')
      new_logger.log("this", "that", "the other thing")
      log_file.should == "/\nthis, that, the other thing"
    end
  end
end
