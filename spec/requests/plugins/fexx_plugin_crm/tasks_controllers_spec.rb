require 'rails_helper'

RSpec.describe 'Plugins::FexxPluginCrm::TasksControllers', type: :request do
  describe 'GET /admin/next/tasks' do
    it 'show tasks list' do
      sign_in
      get admin_tasks_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /admin/next/tasks' do
    it 'create new phone call task' do
      contact = create :contact
      sign_in
      expect do
        post admin_tasks_path, task: {
          contact_id: contact.id,
          task_type: 'phone_call',
          title: 'Test task',
          details: 'Test phone call task',
          due_date: Time.current.strftime('%m/%d/%Y - %I:%M %p'),
          notes_attributes: [{ details: 'Note for test call task' }]
        }
      end.to change { contact.tasks.count }.by 1
      expect(response).to redirect_to action: :index
    end
  end
end
