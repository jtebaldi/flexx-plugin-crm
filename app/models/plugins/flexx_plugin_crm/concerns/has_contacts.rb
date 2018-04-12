module Plugins::FlexxPluginCrm::Concerns::HasContacts
  extend ActiveSupport::Concern

  included do
    has_many :contacts, class_name: "Plugins::FlexxPluginCrm::Contact"
  end
end
