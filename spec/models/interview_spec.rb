require 'spec_helper'

describe Interview do
  let(:now) { Time.now }
  before :each do
    Timecop.freeze(now)
  end

  def with_attrs(attrs = {})
    build(:interview, attrs)
  end

  describe 'validations' do
    context 'defaults' do
      let(:subject) { with_attrs }
      it { should have(:no).errors }
    end

    context 'request_date' do
      context 'presence' do
        let(:subject) { with_attrs({request_date: nil}) }
        it { should have(1).errors_on(:request_date) }
      end
      context 'future request' do
        context 'in the past' do
          let(:subject) { with_attrs({request_date: now - 1.day}) }
          it { should have(1).errors_on(:request_date) }
        end
        context 'valid' do
          let(:subject) { with_attrs({request_date: now + 1.day}) }
          it { should have(0).errors_on(:request_date) }
        end
      end
    end

    context 'unique index (company_id, user_id, job_listing_id)' do
      before :each do
        create(:interview, company_id: company.id, job_listing_id: job_listing.id, user_id: user.id, request_date: now + 1.day )
      end
      let(:company)     { create(:company) }
      let(:job_listing) { create(:job_listing) }
      let(:user)        { create(:user) }
      let(:subject)     { with_attrs({company_id: company.id, job_listing_id: job_listing.id, user_id: user.id, request_date: now + 1.day}) }
      it { should have(1).errors_on(:user_id) }
    end
  end
end
