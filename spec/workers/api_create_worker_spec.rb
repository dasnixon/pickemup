require 'spec_helper'

describe APICreateWorker do
  let (:job_listing) { create(:job_listing, active: true) }
  let (:api_response) { double('api_response') }

  before :each do
    JobListing.should_receive(:find).with(job_listing.id).and_return(job_listing)
    job_listing.should_receive(:api_create).and_return(api_response)
  end

  context 'when the API responds successfully' do
    it 'should not log anything' do
      api_response.stub(:status).and_return(200)
      APILogger.should_not_receive(:new)
      APICreateWorker.new.perform(job_listing.id, job_listing.class.name)
    end
  end

  context 'when the API responds unsuccessfully' do
    let (:api_logger) { double('api_logger') }

    it 'should log the model ID, class name, and response status' do
      api_response.stub(:status).and_return(500)
      APILogger.should_receive(:new).with('CREATE').and_return(api_logger)
      api_logger.should_receive(:log).with(job_listing.id, job_listing.class.name, api_response.status)
      APICreateWorker.new.perform(job_listing.id, job_listing.class.name)
    end
  end
end
