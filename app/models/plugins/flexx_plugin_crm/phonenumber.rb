class Plugins::FlexxPluginCrm::Phonenumber < ActiveRecord::Base
  self.table_name = 'phonenumbers'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'

  before_create :set_phonetype

  private

  def set_phonetype
    self.phone_type = 'other' if self.phone_type.blank?
  end
end
