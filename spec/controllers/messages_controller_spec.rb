require 'spec_helper'

describe MessagesController do
  context 'user\'s messages' do
    let(:user) { create(:user) }
    describe '#index' do
      before :each do
        get(:index, user_id: user.id)
      end
      it { should respond_with(:redirect) }
      it { should redirect_to(user_conversations_path(box: 'inbox')) }
    end

    describe '#show' do
      context 'no message found' do
        before :each do
          user_login(user)
          Message.stub(:find).and_return(nil)
          User.stub(:find).and_return(user)
          get(:show, {user_id: user.id, id: 'mailbox_id'})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(user_conversations_path(box: 'inbox')) }
      end
      context 'message found' do
        let(:message) { double('message', conversation: nil) }
        context 'conversation not found' do
          before :each do
            user_login(user)
            Message.stub(:find).and_return(message)
            User.stub(:find).and_return(user)
            get(:show, {user_id: user.id, id: 'message_id'})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(user_conversations_path(box: 'inbox')) }
        end
        context 'conversation found' do
          context 'user is participant in conversation' do
            let(:conversation) { double('conversation', is_participant?: true, id: 'conversation') }
            let(:message) { double('message', conversation: conversation) }
            before :each do
              user_login(user)
              Message.stub(:find).and_return(message)
              User.stub(:find).and_return(user)
              get(:show, {user_id: user.id, id: 'message_id'})
            end
            it { should respond_with(:redirect) }
            it { should redirect_to(user_conversation_path(user_id: user.id, id: 'conversation', box: :sentbox)) }
          end
          context 'user not participant' do
            let(:conversation) { double('conversation', is_participant?: false) }
            let(:message) { double('message', conversation: conversation) }
            before :each do
              user_login(user)
              Message.stub(:find).and_return(message)
              User.stub(:find).and_return(user)
              get(:show, {user_id: user.id, id: 'message_id'})
            end
            it { should respond_with(:redirect) }
            it { should redirect_to(user_conversations_path(box: 'inbox')) }
          end
        end
      end
    end

    describe '#new' do
      before :each do
        User.stub(:find).and_return(user)
      end
      context 'invalid params' do
        context 'missing receiver' do
          before :each do
            user_login(user)
            get(:new, {user_id: user.id, receiver: nil, job_listing_id: 'id'})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(user_conversations_path(box: 'inbox')) }
        end
        context 'missing job listing' do
          before :each do
            user_login(user)
            get(:new, {user_id: user.id, receiver: 'bob', job_listing_id: nil})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(user_conversations_path(box: 'inbox')) }
        end
      end
      context 'valid params' do
        let(:job_listing) { create(:job_listing) }
        let(:recipient) { create(:company) }
        context 'invalid request' do
          context 'invalid recipient' do
            before :each do
              expect(Company).to receive(:find).with('not good').and_return(nil)
              user_login(user)
              get(:new, {user_id: user.id, receiver: 'not good', job_listing_id: job_listing.id})
            end
            it { should respond_with(:redirect) }
            it { should redirect_to(user_conversations_path(box: 'inbox')) }
            it 'has flash notice' do
              flash[:notice].should eq 'Missing a valid recipient or job listing'
            end
          end
          context 'invalid job listing' do
            before :each do
              expect(Company).to receive(:find).and_return(recipient)
              expect(JobListing).to receive(:find).and_return(nil)
              user_login(user)
              get(:new, {user_id: user.id, receiver: recipient.id, job_listing_id: 'bad listing'})
            end
            it { should respond_with(:redirect) }
            it { should redirect_to(user_conversations_path(box: 'inbox')) }
            it 'has flash notice' do
              flash[:notice].should eq 'Missing a valid recipient or job listing'
            end
          end
          context 'sending to self' do
            before :each do
              expect(Company).to receive(:find).and_return(user)
              expect(JobListing).to receive(:find).and_return(job_listing)
              user_login(user)
              get(:new, {user_id: user.id, receiver: recipient.id, job_listing_id: job_listing.id})
            end
            it { should respond_with(:redirect) }
            it { should redirect_to(user_conversations_path(box: 'inbox')) }
            it 'has flash notice' do
              flash[:notice].should eq 'Missing a valid recipient or job listing'
            end
          end
        end
        context 'valid request' do
          before :each do
            expect(Company).to receive(:find).and_return(recipient)
            expect(JobListing).to receive(:find).and_return(job_listing)
            user_login(user)
            get(:new, {user_id: user.id, receiver: recipient.id, job_listing_id: job_listing.id})
          end
          it { should respond_with(:success) }
          it('has job listing variable') { assigns(:job_listing).should eq job_listing }
          it('has recipient variable') { assigns(:recipient).should eq recipient }
          it('has mailbox_for variable') { assigns(:mailbox_for).should eq user }
        end
      end
    end

    describe '#create' do
      before :each do
        User.stub(:find).and_return(user)
      end
      context 'invalid params' do
        context 'missing receiver' do
          before :each do
            user_login(user)
            post(:create, {user_id: user.id, receiver: nil, job_listing_id: 'id'})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(user_conversations_path(box: 'inbox')) }
        end
        context 'missing job listing' do
          before :each do
            user_login(user)
            post(:create, {user_id: user.id, receiver: 'bob', job_listing_id: nil})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(user_conversations_path(box: 'inbox')) }
        end
      end
      context 'valid params' do
        let(:job_listing) { create(:job_listing) }
        let(:recipient) { create(:company) }
        context 'invalid request' do
          context 'invalid recipient' do
            before :each do
              expect(Company).to receive(:find).with('not good').and_return(nil)
              user_login(user)
              post(:create, {user_id: user.id, receiver: 'not good', job_listing_id: job_listing.id})
            end
            it { should respond_with(:redirect) }
            it { should redirect_to(user_conversations_path(box: 'inbox')) }
            it 'has flash notice' do
              flash[:notice].should eq 'Missing a valid recipient or job listing'
            end
          end
          context 'invalid job listing' do
            before :each do
              expect(Company).to receive(:find).and_return(recipient)
              expect(JobListing).to receive(:find).and_return(nil)
              user_login(user)
              post(:create, {user_id: user.id, receiver: recipient.id, job_listing_id: 'bad listing'})
            end
            it { should respond_with(:redirect) }
            it { should redirect_to(user_conversations_path(box: 'inbox')) }
            it 'has flash notice' do
              flash[:notice].should eq 'Missing a valid recipient or job listing'
            end
          end
          context 'sending to self' do
            before :each do
              expect(Company).to receive(:find).and_return(user)
              expect(JobListing).to receive(:find).and_return(job_listing)
              user_login(user)
              post(:create, {user_id: user.id, receiver: recipient.id, job_listing_id: job_listing.id})
            end
            it { should respond_with(:redirect) }
            it { should redirect_to(user_conversations_path(box: 'inbox')) }
            it 'has flash notice' do
              flash[:notice].should eq 'Missing a valid recipient or job listing'
            end
          end
          context 'subject blank' do
            before :each do
              expect(Company).to receive(:find).and_return(recipient)
              expect(JobListing).to receive(:find).and_return(job_listing)
              user_login(user)
              post(:create, {user_id: user.id, receiver: recipient.id, job_listing_id: job_listing.id, body: 'body', subject: nil})
            end
            it { should respond_with(:success) }
            it { should render_template(:new) }
            it 'has errors on receipt object' do
              assigns(:receipt).errors.should_not be_empty
            end
          end
          context 'body blank' do
            before :each do
              expect(Company).to receive(:find).and_return(recipient)
              expect(JobListing).to receive(:find).and_return(job_listing)
              user_login(user)
              post(:create, {user_id: user.id, receiver: recipient.id, job_listing_id: job_listing.id, body: nil, subject: 'subject'})
            end
            it { should respond_with(:success) }
            it { should render_template(:new) }
            it 'has errors on receipt object' do
              assigns(:receipt).errors.should_not be_empty
            end
          end
        end
        context 'valid request' do
          before :each do
            expect(Company).to receive(:find).and_return(recipient)
            expect(JobListing).to receive(:find).and_return(job_listing)
            user_login(user)
            post(:create, {user_id: user.id, receiver: recipient.id, job_listing_id: job_listing.id, body: 'body', subject: 'subject'})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(user_conversation_path(user_id: user.id, id: assigns(:conversation).id, box: :sentbox)) }
          it 'has errors on receipt object' do
            assigns(:receipt).errors.should be_empty
          end
        end
      end
    end
  end
end
