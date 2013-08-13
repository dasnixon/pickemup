require 'spec_helper'

describe SubscriptionsController do
  let(:company) { create(:company) }
  describe '#new' do
    context 'invalid company' do
      context 'not logged in' do
        before :each do
          expect(Company).to receive(:find).and_return(company)
          get(:new, {company_id: company.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
        it('has flash alert') { flash[:alert].should eq 'You do not have permissions to view this page' }
      end
      context 'company not found' do
        before :each do
          company_login(company)
          Company.stub(:find).and_return(nil)
          get(:new, {company_id: 'blah'})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
        it('has flash alert') { flash[:alert].should eq 'You do not have permissions to view this page' }
      end
    end
    context 'valid company' do
      let(:subscription) { double(Subscription) }
      before :each do
        company_login(company)
        Company.stub(:find).and_return(company)
        expect(Subscription).to receive(:new).and_return(subscription)
        get(:new, {company_id: company.id})
      end
      it('sets subscription variable') { assigns(:subscription).should eq subscription }
    end
  end

  describe '#create' do
    let(:company) { double(Company, id: '1', build_subscription: subscription, mailbox: inbox) }
    let(:inbox) { double(Conversation, inbox: [message]) }
    let(:message) { double('message', is_unread?: false) }
    context 'valid payment' do
      let(:subscription) { double(Subscription, save_with_payment: true) }
      before :each do
        company_login(company)
        Company.stub(:find).and_return(company)
        post(:create, {company_id: company.id, email: 'test@test.com', plan: 0, stripe_card_token: '123'})
      end
      it { should respond_with(:redirect) }
      it { should redirect_to(root_path) }
      it 'has flash notice' do
        flash[:notice].should eq 'Subscription created! Start by adding a job listing.'
      end
    end
    context 'invalid payment' do
      let(:subscription) { double(Subscription, save_with_payment: false) }
      before :each do
        company_login(company)
        Company.stub(:find).and_return(company)
        post(:create, {company_id: company.id, email: 'test@test.com', plan: 0, stripe_card_token: '123'})
      end
      it { should respond_with(:success) }
      it { should render_template(:new) }
      it 'has flash error' do
        flash[:error].should eq 'We had trouble adding your payment information, try again.'
      end
    end
  end

  describe '#edit' do
    before :each do
      Company.stub(:find).and_return(company)
      company_login(company)
    end
    context 'invalid credentials' do
      context 'no subscription' do
        before :each do
          company.stub(:subscription).and_return(nil)
          get(:edit, {company_id: company.id, id: '1'})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(edit_company_path(id: company.id)) }
        it 'has flash alert' do
          flash[:alert].should eq 'Unable to retrieve your stripe information at this time, try again.'
        end
      end
      context 'no customer information from stripe' do
        let(:subscription) { double(Subscription, stripe_customer_token: '123', retrieve_stripe_info: nil) }
        before :each do
          company.stub(:subscription).and_return(subscription)
          get(:edit, {company_id: company.id, id: '1'})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(edit_company_path(id: company.id)) }
        it 'has flash alert' do
          flash[:alert].should eq 'Unable to retrieve your stripe information at this time, try again.'
        end
      end
    end
    context 'vaild credentials' do
      let(:subscription) { double(Subscription, stripe_customer_token: '123', retrieve_stripe_info: 'customer') }
      before :each do
        company.stub(:subscription).and_return(subscription)
        get(:edit, {company_id: company.id, id: '1'})
      end
      it { should respond_with(:success) }
      it('has customer variable') { assigns(:customer).should eq 'customer' }
      it('has subscription variable') { assigns(:subscription).should eq subscription }
      it('has company variable') { assigns(:company).should eq company }
    end
  end

  describe '#update' do
    before :each do
      Company.stub(:find).and_return(company)
      company_login(company)
    end
    context 'invalid credentials' do
      context 'no subscription' do
        before :each do
          company.stub(:subscription).and_return(nil)
          put(:update, {company_id: company.id, id: '1'})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(edit_company_path(id: company.id)) }
        it 'has flash alert' do
          flash[:alert].should eq 'Unable to retrieve your stripe information at this time, try again.'
        end
      end
      context 'no customer information from stripe' do
        let(:subscription) { double(Subscription, stripe_customer_token: '123', retrieve_stripe_info: nil) }
        before :each do
          company.stub(:subscription).and_return(subscription)
          put(:update, {company_id: company.id, id: '1'})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(edit_company_path(id: company.id)) }
        it 'has flash alert' do
          flash[:alert].should eq 'Unable to retrieve your stripe information at this time, try again.'
        end
      end
    end
    context 'valid credentials' do
      context 'invalid request' do
        context 'customer invalid doesn\'t save' do
          let(:customer) { double('stripe_customer', save: false) }
          let(:subscription) { create(:subscription, plan: 2) }
          before :each do
            company.stub(:subscription).and_return(subscription)
            subscription.stub(:retrieve_stripe_info).and_return(customer)
            put(:update, {company_id: company.id, id: '1', plan: subscription.plan})
          end
          it { should respond_with(:success) }
          it { should render_template(:edit) }
          it('has flash error') { flash[:error].should eq 'We had trouble updating your payment information, try again.' }
        end
        context 'subscription invalid doesn\t save' do
          let(:customer) { double('stripe_customer', save: true) }
          let(:subscription) { create(:subscription, plan: 2) }
          before :each do
            company.stub(:subscription).and_return(subscription)
            subscription.stub(:retrieve_stripe_info).and_return(customer)
            subscription.stub(:save_update).and_return(false)
            put(:update, {company_id: company.id, id: '1', plan: subscription.plan})
          end
          it { should respond_with(:success) }
          it { should render_template(:edit) }
          it('has flash error') { flash[:error].should eq 'We had trouble updating your payment information, try again.' }
        end
      end
      context 'valid request' do
        context 'cancellation' do
          let(:customer) { double('stripe_customer', save: true) }
          let(:subscription) { create(:subscription, plan: 2) }
          before :each do
            company.stub(:subscription).and_return(subscription)
            subscription.stub(:retrieve_stripe_info).and_return(customer)
            expect(customer).to receive(:cancel_subscription).and_return(true)
            put(:update, {company_id: company.id, id: '1', cancel_subscription: 'true', plan: subscription.plan})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(edit_company_path(id: company.id)) }
          it('has flash notice') { flash[:notice].should eq 'Subscription information has been updated successfully.' }
          it('sets subscription active to false') { subscription.active.should be_false }
        end
        context 'changed plan' do
          let(:customer) { double('stripe_customer', save: true) }
          let(:subscription) { create(:subscription, plan: 2) }
          before :each do
            company.stub(:subscription).and_return(subscription)
            subscription.stub(:retrieve_stripe_info).and_return(customer)
            expect(customer).to receive(:update_subscription).and_return(true)
            put(:update, {company_id: company.id, id: '1', plan: 1})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(edit_company_path(id: company.id)) }
          it('has flash notice') { flash[:notice].should eq 'Subscription information has been updated successfully.' }
          it('updates subscription plan to 1') { subscription.plan.should eq 1 }
        end
        context 'reactivation' do
          let(:customer) { double('stripe_customer', save: true) }
          let(:subscription) { create(:subscription, plan: 2) }
          before :each do
            company.stub(:subscription).and_return(subscription)
            subscription.stub(:retrieve_stripe_info).and_return(customer)
            expect(customer).to receive(:update_subscription).and_return(true)
            put(:update, {company_id: company.id, id: '1', plan: subscription.plan, reactivate_subscription: 'true'})
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(edit_company_path(id: company.id)) }
          it('has flash notice') { flash[:notice].should eq 'Subscription information has been updated successfully.' }
          it('sets subscription active to true') { subscription.active.should be_true }
        end
      end
    end
  end

  describe '#edit_card' do
    before :each do
      Company.stub(:find).and_return(company)
      company_login(company)
    end
    context 'stripe card token present PUT' do
      context 'valid update' do
        let(:customer) { double('stripe_customer') }
        let(:subscription) { create(:subscription) }
        before :each do
          company.stub(:subscription).and_return(subscription)
          subscription.stub(:retrieve_stripe_info).and_return(customer)
          expect(customer).to receive(:update_subscription).and_return(true)
          put(:edit_card, {company_id: company.id, id: '1', stripe_card_token: '123456'})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(edit_company_path(id: company.id)) }
        it('has flash notice') { flash[:notice].should eq 'Successfully updated payment information.' }
      end
      context 'invalid update' do
        let(:customer) { double('stripe_customer') }
        let(:subscription) { create(:subscription) }
        before :each do
          company.stub(:subscription).and_return(subscription)
          subscription.stub(:retrieve_stripe_info).and_return(customer)
          subscription.stub(:update).and_return(false)
          expect(customer).to receive(:update_subscription).and_return(true)
          put(:edit_card, {company_id: company.id, id: '1', stripe_card_token: '123456'})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(edit_company_path(id: company.id)) }
        it('has flash notice') { flash[:notice].should eq 'Unable to update payment information at this time.' }
      end
    end
    context 'no stripe card token present, basic GET request' do
      let(:customer) { double('stripe_customer') }
      let(:subscription) { create(:subscription) }
      before :each do
        company.stub(:subscription).and_return(subscription)
        subscription.stub(:retrieve_stripe_info).and_return(customer)
        get(:edit_card, {company_id: company.id, id: '1'})
      end
      it { should respond_with(:success) }
      it('has company object') { assigns(:company).should eq company }
      it('has customer object') { assigns(:customer).should eq customer }
    end
  end

  describe '#purchase_options' do
    context 'invalid company' do
      context 'not logged in' do
        before :each do
          expect(Company).to receive(:find).and_return(company)
          get(:purchase_options, {company_id: company.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
        it('has flash alert') { flash[:alert].should eq 'You do not have permissions to view this page' }
      end
      context 'company not found' do
        before :each do
          company_login(company)
          Company.stub(:find).and_return(nil)
          get(:purchase_options, {company_id: 'blah'})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
        it('has flash alert') { flash[:alert].should eq 'You do not have permissions to view this page' }
      end
    end
    context 'valid company' do
      let(:subscription) { double(Subscription) }
      before :each do
        company_login(company)
        Company.stub(:find).and_return(company)
        get(:purchase_options, {company_id: company.id})
      end
      it { should respond_with(:success) }
    end
  end
end
