require 'rails_helper'

RSpec.describe Plugins::FlexxPluginCrm::Contact, type: :model do
  it 'should has status "lead" by default' do
    contact = create :contact
    expect(contact.sales_stage).to eq 'lead'
  end
end
