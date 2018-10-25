class Plugins::FlexxPluginCrm::Phonenumber < ActiveRecord::Base
  self.table_name = 'phonenumbers'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :site, class_name: 'CamaleonCms::Site'

  before_create :set_phonetype

  scope :mobile, -> { where(phone_type: 'mobile') }

  private

  def set_phonetype
    self.phone_type = 'mobile' if self.phone_type.blank?
  end
end
