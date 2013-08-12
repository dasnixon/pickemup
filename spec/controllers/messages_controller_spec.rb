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

    end

    describe '#create' do

    end
  end
end
