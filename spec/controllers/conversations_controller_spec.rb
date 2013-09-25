require 'spec_helper'

describe ConversationsController do
  before :each do
    controller.stub(:check_user_messages)
    controller.stub(:check_company_messages)
  end
  context 'user\'s mailbox' do
    let(:user) { create(:user) }
    describe '#index' do
      context 'invalid permissions' do
        context 'company signed in' do
          let(:company) { create(:company) }
          before :each do
            company_login(company)
            get(:index, {user_id: company.id})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(root_path) }
          it 'has error flash' do
            flash[:alert].should eq 'You do not have permissions to view this page'
          end
        end
        context 'user not signed in' do
          before :each do
            get(:index, {user_id: user.id})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(root_path) }
          it 'has error flash' do
            flash[:alert].should eq 'You do not have permissions to view this page'
          end
        end
        context 'viewing other user\'s mailbox' do
          let(:other_user) { create(:user) }
          before :each do
            user_login(user)
            get(:index, {user_id: other_user.id})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(root_path) }
          it 'has error flash' do
            flash[:alert].should eq 'You do not have permissions to view this page'
          end
        end
      end
      context 'valid permissions' do
        let(:mailbox) { double('mailbox') }
        let(:job_listing) { create(:job_listing) }
        let(:inbox_conversations) { create_list(:conversation, 2, job_listing_id: job_listing.id) }
        let(:sent_conversations) { create_list(:conversation, 2, job_listing_id: job_listing.id) }
        let(:trash_conversations) { create_list(:conversation, 2, job_listing_id: job_listing.id) }
        before :each do
          user_login(user)
          User.stub(:find).and_return(user)
        end
        context 'inbox' do
          before :each do
            user.stub(:mailbox).and_return(mailbox)
            mailbox.stub_chain(:inbox, :paginate).and_return(inbox_conversations)
            get(:index, {user_id: user.id, box: 'inbox'})
          end
          it { should respond_with(:success) }
          it 'has conversations variable' do
            assigns(:conversations).should eq inbox_conversations
          end
          it 'has box variable' do
            assigns(:box).should eq 'inbox'
          end
        end
        context 'sentbox' do
          before :each do
            user.stub(:mailbox).and_return(mailbox)
            mailbox.stub_chain(:sentbox, :paginate).and_return(sent_conversations)
            get(:index, {user_id: user.id, box: 'sentbox'})
          end
          it { should respond_with(:success) }
          it 'has conversations variable' do
            assigns(:conversations).should eq sent_conversations
          end
          it 'has box variable' do
            assigns(:box).should eq 'sentbox'
          end
        end
        context 'trash' do
          before :each do
            user.stub(:mailbox).and_return(mailbox)
            mailbox.stub_chain(:trash, :paginate).and_return(trash_conversations)
            get(:index, {user_id: user.id, box: 'trash'})
          end
          it { should respond_with(:success) }
          it 'has conversations variable' do
            assigns(:conversations).should eq trash_conversations
          end
          it 'has box variable' do
            assigns(:box).should eq 'trash'
          end
        end
        context 'no box passed in, defaults to inbox' do
          before :each do
            user.stub(:mailbox).and_return(mailbox)
            mailbox.stub_chain(:inbox, :paginate).and_return(inbox_conversations)
            get(:index, {user_id: user.id})
          end
          it { should respond_with(:success) }
          it 'has conversations variable' do
            assigns(:conversations).should eq inbox_conversations
          end
          it 'has box variable' do
            assigns(:box).should eq 'inbox'
          end
        end
      end
    end

    describe '#show' do
      let(:receipts) { double('receipts', trash: trash_receipts, not_trash: not_trash_receipts) }
      let(:trash_receipts) { double('trash_receipts', mark_as_read: true) }
      let(:not_trash_receipts) { double('not_trash_receipts', mark_as_read: true) }
      let(:mailbox) { double('mailbox', inbox: [conversation], receipts_for: receipts) }
      let(:conversation) { create(:conversation, job_listing_id: job_listing.id) }
      let(:job_listing) { create(:job_listing) }
      context 'invalid conversation' do
        context 'conversation not found' do
          before :each do
            user_login(user)
            user.stub(:mailbox).and_return(mailbox)
            Conversation.stub(:find).and_return(nil)
            get(:show, {id: conversation.id, box: 'inbox', user_id: user.id})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(user_conversations_path(box: 'inbox')) }
          it('has flash notice') { flash[:notice].should eq 'Unable to find conversation' }
        end
        context 'user not participant in conversation' do
          before :each do
            user_login(user)
            user.stub(:mailbox).and_return(mailbox)
            Conversation.stub(:find).and_return(conversation)
            conversation.stub(:is_participant?).and_return(false)
            get(:show, {id: conversation.id, box: 'inbox', user_id: user.id})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(user_conversations_path(box: 'inbox')) }
          it('has flash notice') { flash[:notice].should eq 'Unable to find conversation' }
        end
      end
      context 'sentbox or inbox, not trash' do
        before :each do
          user_login(user)
          User.stub(:find).and_return(user)
          user.stub(:mailbox).and_return(mailbox)
          Conversation.stub(:find).and_return(conversation)
          conversation.stub(:is_participant?).and_return(true)
          get(:show, {id: conversation.id, box: 'inbox', user_id: user.id})
        end
        it { should respond_with(:success) }
        it 'sets receipts variable' do
          assigns(:receipts).should eq not_trash_receipts
        end
        it 'sets box variable' do
          assigns(:box).should eq 'inbox'
        end
        it 'sets conversation variable' do
          assigns(:conversation).should eq conversation
        end
      end
      context 'trash box' do
        before :each do
          user_login(user)
          User.stub(:find).and_return(user)
          user.stub(:mailbox).and_return(mailbox)
          Conversation.stub(:find).and_return(conversation)
          conversation.stub(:is_participant?).and_return(true)
          get(:show, {id: conversation.id, box: 'trash', user_id: user.id})
        end
        it { should respond_with(:success) }
        it 'sets receipts variable' do
          assigns(:receipts).should eq trash_receipts
        end
        it 'sets box variable' do
          assigns(:box).should eq 'trash'
        end
        it 'sets conversation variable' do
          assigns(:conversation).should eq conversation
        end
        it 'sets mailbox variable' do
          assigns(:mailbox).should eq mailbox
        end
      end
    end

    describe '#destroy' do
      let(:mailbox) { double('mailbox', inbox: [conversation]) }
      let(:conversation) { create(:conversation, job_listing_id: job_listing.id) }
      let(:job_listing) { create(:job_listing) }
      before :each do
        user_login(user)
        user.stub(:mailbox).and_return(mailbox)
        Conversation.stub(:find).and_return(conversation)
        conversation.stub(:is_participant?).and_return(true)
        expect(conversation).to receive(:move_to_trash).and_return(true)
      end
      context 'conversation location' do
        before :each do
          delete(:destroy, {user_id: user.id, location: 'conversation', id: conversation.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(user_conversations_path(box: 'trash')) }
        it 'sets conversation variable' do
          assigns(:conversation).should eq conversation
        end
        it 'sets mailbox_for object to user' do
          assigns(:mailbox_for).should eq user
        end
        it 'sets box variable to trash' do
          assigns(:box).should eq 'trash'
        end
        it 'has flash notice' do
          flash[:notice].should eq 'Successfully removed conversation'
        end
      end
      context 'no location present' do
        before :each do
          delete(:destroy, {user_id: user.id, id: conversation.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(user_conversations_path(box: 'inbox')) }
        it 'sets conversation variable' do
          assigns(:conversation).should eq conversation
        end
        it 'sets mailbox_for object to user' do
          assigns(:mailbox_for).should eq user
        end
        it 'sets box variable to inbox' do
          assigns(:box).should eq 'inbox'
        end
        it 'has flash notice' do
          flash[:notice].should eq 'Successfully removed conversation'
        end
      end
    end

    describe '#untrash' do
      let(:mailbox) { double('mailbox', inbox: [conversation]) }
      let(:conversation) { create(:conversation, job_listing_id: job_listing.id) }
      let(:job_listing) { create(:job_listing) }
      before :each do
        user_login(user)
        user.stub(:mailbox).and_return(mailbox)
        Conversation.stub(:find).and_return(conversation)
        conversation.stub(:is_participant?).and_return(true)
        expect(conversation).to receive(:untrash).and_return(true)
        put(:untrash, {id: conversation.id, user_id: user.id})
      end
      it { should respond_with(:redirect) }
      it { should redirect_to(user_conversations_path(box: 'inbox')) }
      it 'sets conversation variable' do
        assigns(:conversation).should eq conversation
      end
      it 'sets mailbox_for object to user' do
        assigns(:mailbox_for).should eq user
      end
      it 'sets box variable to inbox' do
        assigns(:box).should eq 'inbox'
      end
      it 'has flash notice' do
        flash[:notice].should eq 'Successfully untrashed the conversation'
      end
    end
  end

  context 'company\'s mailbox' do
    let(:company) { create(:company) }
    describe '#index' do
      context 'invalid permissions' do
        context 'user signed in' do
          let(:user) { create(:user) }
          before :each do
            user_login(user)
            get(:index, {company_id: user.id})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(root_path) }
          it 'has error flash' do
            flash[:alert].should eq 'You do not have permissions to view this page'
          end
        end
        context 'company not signed in' do
          before :each do
            get(:index, {company_id: company.id})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(root_path) }
          it 'has error flash' do
            flash[:alert].should eq 'You do not have permissions to view this page'
          end
        end
        context 'viewing other company\'s mailbox' do
          let(:other_company) { create(:company) }
          before :each do
            company_login(company)
            get(:index, {company_id: other_company.id})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(root_path) }
          it 'has error flash' do
            flash[:alert].should eq 'You do not have permissions to view this page'
          end
        end
      end
      context 'valid permissions' do
        let(:mailbox) { double('mailbox') }
        let(:job_listing) { create(:job_listing) }
        let(:inbox_conversations) { create_list(:conversation, 2, job_listing_id: job_listing.id) }
        let(:sent_conversations) { create_list(:conversation, 2, job_listing_id: job_listing.id) }
        let(:trash_conversations) { create_list(:conversation, 2, job_listing_id: job_listing.id) }
        before :each do
          company_login(company)
          Company.stub(:find).and_return(company)
        end
        context 'inbox' do
          before :each do
            company.stub(:mailbox).and_return(mailbox)
            mailbox.stub_chain(:inbox, :paginate).and_return(inbox_conversations)
            get(:index, {company_id: company.id, box: 'inbox'})
          end
          it { should respond_with(:success) }
          it 'has conversations variable' do
            assigns(:conversations).should eq inbox_conversations
          end
          it 'has box variable' do
            assigns(:box).should eq 'inbox'
          end
        end
        context 'sentbox' do
          before :each do
            company.stub(:mailbox).and_return(mailbox)
            mailbox.stub_chain(:sentbox, :paginate).and_return(sent_conversations)
            get(:index, {company_id: company.id, box: 'sentbox'})
          end
          it { should respond_with(:success) }
          it 'has conversations variable' do
            assigns(:conversations).should eq sent_conversations
          end
          it 'has box variable' do
            assigns(:box).should eq 'sentbox'
          end
        end
        context 'trash' do
          before :each do
            company.stub(:mailbox).and_return(mailbox)
            mailbox.stub_chain(:trash, :paginate).and_return(trash_conversations)
            get(:index, {company_id: company.id, box: 'trash'})
          end
          it { should respond_with(:success) }
          it 'has conversations variable' do
            assigns(:conversations).should eq trash_conversations
          end
          it 'has box variable' do
            assigns(:box).should eq 'trash'
          end
        end
        context 'no box passed in, defaults to inbox' do
          before :each do
            company.stub(:mailbox).and_return(mailbox)
            mailbox.stub_chain(:inbox, :paginate).and_return(inbox_conversations)
            get(:index, {company_id: company.id})
          end
          it { should respond_with(:success) }
          it 'has conversations variable' do
            assigns(:conversations).should eq inbox_conversations
          end
          it 'has box variable' do
            assigns(:box).should eq 'inbox'
          end
        end
      end
    end

    describe '#show' do
      let(:receipts) { double('receipts', trash: trash_receipts, not_trash: not_trash_receipts) }
      let(:trash_receipts) { double('trash_receipts', mark_as_read: true) }
      let(:not_trash_receipts) { double('not_trash_receipts', mark_as_read: true) }
      let(:mailbox) { double('mailbox', inbox: [conversation], receipts_for: receipts) }
      let(:conversation) { create(:conversation, job_listing_id: job_listing.id) }
      let(:job_listing) { create(:job_listing) }
      context 'invalid conversation' do
        context 'conversation not found' do
          before :each do
            company_login(company)
            company.stub(:mailbox).and_return(mailbox)
            Conversation.stub(:find).and_return(nil)
            get(:show, {id: conversation.id, box: 'inbox', company_id: company.id})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(company_conversations_path(box: 'inbox')) }
          it('has flash notice') { flash[:notice].should eq 'Unable to find conversation' }
        end
        context 'company not participant in conversation' do
          before :each do
            company_login(company)
            company.stub(:mailbox).and_return(mailbox)
            Conversation.stub(:find).and_return(conversation)
            conversation.stub(:is_participant?).and_return(false)
            get(:show, {id: conversation.id, box: 'inbox', company_id: company.id})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(company_conversations_path(box: 'inbox')) }
          it('has flash notice') { flash[:notice].should eq 'Unable to find conversation' }
        end
      end
      context 'sentbox or inbox, not trash' do
        before :each do
          company_login(company)
          Company.stub(:find).and_return(company)
          company.stub(:mailbox).and_return(mailbox)
          Conversation.stub(:find).and_return(conversation)
          conversation.stub(:is_participant?).and_return(true)
          get(:show, {id: conversation.id, box: 'inbox', company_id: company.id})
        end
        it { should respond_with(:success) }
        it 'sets receipts variable' do
          assigns(:receipts).should eq not_trash_receipts
        end
        it 'sets box variable' do
          assigns(:box).should eq 'inbox'
        end
        it 'sets conversation variable' do
          assigns(:conversation).should eq conversation
        end
      end
      context 'trash box' do
        before :each do
          company_login(company)
          Company.stub(:find).and_return(company)
          company.stub(:mailbox).and_return(mailbox)
          Conversation.stub(:find).and_return(conversation)
          conversation.stub(:is_participant?).and_return(true)
          get(:show, {id: conversation.id, box: 'trash', company_id: company.id})
        end
        it { should respond_with(:success) }
        it 'sets receipts variable' do
          assigns(:receipts).should eq trash_receipts
        end
        it 'sets box variable' do
          assigns(:box).should eq 'trash'
        end
        it 'sets conversation variable' do
          assigns(:conversation).should eq conversation
        end
        it 'sets mailbox variable' do
          assigns(:mailbox).should eq mailbox
        end
      end
    end

    describe '#destroy' do
      let(:mailbox) { double('mailbox', inbox: [conversation]) }
      let(:conversation) { create(:conversation, job_listing_id: job_listing.id) }
      let(:job_listing) { create(:job_listing) }
      before :each do
        company_login(company)
        company.stub(:mailbox).and_return(mailbox)
        Conversation.stub(:find).and_return(conversation)
        conversation.stub(:is_participant?).and_return(true)
        expect(conversation).to receive(:move_to_trash).and_return(true)
      end
      context 'conversation location' do
        before :each do
          delete(:destroy, {company_id: company.id, location: 'conversation', id: conversation.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(company_conversations_path(box: 'trash')) }
        it 'sets conversation variable' do
          assigns(:conversation).should eq conversation
        end
        it 'sets mailbox_for object to company' do
          assigns(:mailbox_for).should eq company
        end
        it 'sets box variable to trash' do
          assigns(:box).should eq 'trash'
        end
        it 'has flash notice' do
          flash[:notice].should eq 'Successfully removed conversation'
        end
      end
      context 'no location present' do
        before :each do
          delete(:destroy, {company_id: company.id, id: conversation.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(company_conversations_path(box: 'inbox')) }
        it 'sets conversation variable' do
          assigns(:conversation).should eq conversation
        end
        it 'sets mailbox_for object to company' do
          assigns(:mailbox_for).should eq company
        end
        it 'sets box variable to inbox' do
          assigns(:box).should eq 'inbox'
        end
        it 'has flash notice' do
          flash[:notice].should eq 'Successfully removed conversation'
        end
      end
    end

    describe '#untrash' do
      let(:mailbox) { double('mailbox', inbox: [conversation]) }
      let(:conversation) { create(:conversation, job_listing_id: job_listing.id) }
      let(:job_listing) { create(:job_listing) }
      before :each do
        company_login(company)
        company.stub(:mailbox).and_return(mailbox)
        Conversation.stub(:find).and_return(conversation)
        conversation.stub(:is_participant?).and_return(true)
        expect(conversation).to receive(:untrash).and_return(true)
        put(:untrash, {id: conversation.id, company_id: company.id})
      end
      it { should respond_with(:redirect) }
      it { should redirect_to(company_conversations_path(box: 'inbox')) }
      it 'sets conversation variable' do
        assigns(:conversation).should eq conversation
      end
      it 'sets mailbox_for object to company' do
        assigns(:mailbox_for).should eq company
      end
      it 'sets box variable to inbox' do
        assigns(:box).should eq 'inbox'
      end
      it 'has flash notice' do
        flash[:notice].should eq 'Successfully untrashed the conversation'
      end
    end
  end
end
