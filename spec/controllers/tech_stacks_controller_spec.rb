require 'spec_helper'

describe TechStacksController do
  let(:company) { create(:company) }
  describe '#index' do
    context 'invalid request' do
      context 'company not logged in' do
        before :each do
          Company.stub(:find).and_return(company)
          get(:index, {company_id: company.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
        it('has flash alert') { flash[:alert].should eq 'You do not have permissions to view this page' }
      end
      context 'trying to peep another company\'s tech stack' do
        let(:other_company) { create(:company) }
        before :each do
          company_login(other_company)
          get(:index, {company_id: company.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
        it('has flash alert') { flash[:alert].should eq 'You do not have permissions to view this page' }
      end
    end
    context 'valid request' do
      let(:tech_stacks) { create_list(:tech_stack, 3, company: company) }
      before :each do
        company_login(company)
        Company.stub(:find).and_return(company)
        expect(company).to receive(:tech_stacks).and_return(tech_stacks)
        get(:index, {company_id: company.id})
      end
      it { should respond_with(:success) }
      it('assigns tech_stacks variable') { assigns(:tech_stacks).should eq tech_stacks }
    end
  end

  describe '#new' do
    let(:tech_stack) { double(TechStack, get_preference_defaults: true) }
    before :each do
      company_login(company)
      Company.stub(:find).and_return(company)
      company.stub_chain(:tech_stacks, :build).and_return(tech_stack)
      get(:new, {company_id: company.id})
    end
    it { should respond_with(:success) }
    it('assigns tech_stack variable') { assigns(:tech_stack).should eq tech_stack }
  end

  describe '#create' do
    before :each do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end
    let(:tech_stack) { build(:tech_stack) }
    let(:name) do
      {name: Faker::Name.name}
    end
    let(:parameters) do
      { company_id: company.id, tech_stack: name }
    end
    before :each do
      company_login(company)
      Company.stub(:find).and_return(company)
      company.stub_chain(:tech_stacks, :build).and_return(tech_stack)
      TechStack.stub(:cleanup_invalid_data).and_return(name)
    end
    context 'valid create' do
      before :each do
        post(:create, parameters)
      end
      it { should respond_with(201) }
      it('assigns tech_stack variable') { assigns(:tech_stack).should eq tech_stack }
    end
    context 'invalid create' do
      before :each do
        tech_stack.stub(:update).and_return(false)
        post(:create, parameters)
      end
      it { should respond_with(:bad_request) }
      it('assigns tech_stack variable') { assigns(:tech_stack).should eq tech_stack }
    end
  end

  describe '#retrieve_tech_stack' do
    before :each do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end
    let(:tech_stack) { create(:tech_stack) }
    let(:parameters) do
      { company_id: company.id, id: tech_stack.id }
    end
    before :each do
      company_login(company)
      Company.stub(:find).and_return(company)
      TechStack.stub(:find).and_return(tech_stack)
      tech_stack.stub(:get_preference_defaults)
      get(:retrieve_tech_stack, parameters)
    end
    it { should respond_with(200) }
    it('assigns tech_stack variable') { assigns(:tech_stack).should eq tech_stack }
  end

  describe '#update_tech_stack' do
    before :each do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end
    let(:tech_stack) { create(:tech_stack) }
    let(:parameters) do
      { company_id: company.id, id: tech_stack.id, tech_stack: { name: 'Front-end' }}
    end
    before :each do
      company_login(company)
      Company.stub(:find).and_return(company)
      TechStack.stub(:find).and_return(tech_stack)
      tech_stack.stub(:get_preference_defaults)
    end
    context 'valid request' do
      before :each do
        put(:update_tech_stack, parameters)
      end
      it { should respond_with(204) }
      it('assigns tech_stack variable') { assigns(:tech_stack).should eq tech_stack }
      it('updates tech stack name') { tech_stack.name.should eq 'Front-end' }
    end
    context 'invalid request' do
      before :each do
        tech_stack.stub(:update).and_return(false)
        put(:update_tech_stack, parameters)
      end
      it { should respond_with(:bad_request) }
      it('assigns tech_stack variable') { assigns(:tech_stack).should eq tech_stack }
      it('does not update the tech stack name') { tech_stack.name.should_not eq 'Front-end' }
    end
  end
end
