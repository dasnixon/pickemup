require 'spec_helper'

describe Trackable do
  let(:user)    { create(:user, sign_in_count: 3, last_sign_in_at: now - 2.days) }
  let(:now)     { Time.now.utc }
  let(:request) { OpenStruct.new(remote_ip: '127.0.0.1') }
  before :each do
    Timecop.freeze(now)
  end
  after :each do
    Timecop.return
  end
  describe '#update_tracked_fields!' do
    it 'iterates sign in count by 1' do
      user.update_tracked_fields!(request)
      user.sign_in_count.should eq 4
    end
    it 'sets current signed in to current time' do
      user.update_tracked_fields!(request)
      user.current_sign_in_at.should eq now
    end
    context 'sign in time' do
      context 'first login, current_sign_in_at not set' do
        it 'sets current signed in to current time' do
          user.update_tracked_fields!(request)
          user.current_sign_in_at.should eq now
        end
        it 'sets last signed in to current time' do
          user.update_tracked_fields!(request)
          user.last_sign_in_at.should eq now
        end
      end
      context 'logged in before' do
        before :each do
          user.current_sign_in_at = now - 1.day
        end
        it 'sets current signed in to current time' do
          user.update_tracked_fields!(request)
          user.current_sign_in_at.should eq now
        end
        it 'sets last signed in to old current_sign_in_at' do
          user.update_tracked_fields!(request)
          user.last_sign_in_at.should eq now - 1.day
        end
      end
    end
    context 'sign in ip address' do
      context 'first login, current_sign_in_ip not set' do
        it 'sets current signed in to new ip' do
          user.update_tracked_fields!(request)
          user.current_sign_in_ip.should eq request.remote_ip
        end
        it 'sets last signed in to remote ip' do
          user.update_tracked_fields!(request)
          user.last_sign_in_ip.should eq request.remote_ip
        end
      end
      context 'logged in before' do
        before :each do
          user.current_sign_in_ip = '255.1.1.1'
        end
        it 'sets current signed in to remote ip' do
          user.update_tracked_fields!(request)
          user.current_sign_in_ip.should eq request.remote_ip
        end
        it 'sets last signed in to old current_sign_in_ip' do
          user.update_tracked_fields!(request)
          user.last_sign_in_ip.should eq '255.1.1.1'
        end
      end
    end
  end
end
