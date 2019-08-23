require 'acts-as-taggable-on'

Rails.application.config.to_prepare do
  CamaleonCms::Site.class_eval do
    include Plugins::FlexxPluginCrm::Concerns::HasContacts
    include Plugins::FlexxPluginCrm::Concerns::HasTasks

    acts_as_tagger

    has_many :task_recipes, class_name: 'Plugins::FlexxPluginCrm::TaskRecipe'
    has_many :automated_campaigns, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaign'
    has_many :automated_campaign_jobs, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignJob'
    has_many :emails, class_name: 'Plugins::FlexxPluginCrm::Email'
    has_many :messages, class_name: 'Plugins::FlexxPluginCrm::Message'
    has_many :phonenumbers, class_name: 'Plugins::FlexxPluginCrm::Phonenumber'
    has_many :stocks, class_name: 'Plugins::FlexxPluginCrm::Stock'
    has_many :message_blasts, class_name: 'Plugins::FlexxPluginCrm::MessageBlast'
  end

  Plugins::CamaContactForm::CamaContactForm.class_eval do
    has_many :task_recipe_to_contact_form_associations, class_name: 'Plugins::FlexxPluginCrm::TaskRecipeToContactFormAssociation'
    has_many :task_recipes, class_name: 'Plugins::FlexxPluginCrm::TaskRecipe', through: :task_recipe_to_contact_form_associations

    has_many :automated_campaign_to_contact_form_associations, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignToContactFormAssociation'
    has_many :automated_campaigns, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaign', through: :automated_campaign_to_contact_form_associations

    belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'

    belongs_to :parent, class_name: 'Plugins::CamaContactForm::CamaContactForm'

    after_create :add_contact

    def add_contact
      return unless parent_id

      cids = parent.fields.reduce({}) do |h, f|
        if f['field_type'] == 'email'
          h.merge email: f['cid']
        else
          case f['label'].downcase when 'first name' then h.merge(first_name: f['cid'])
          when 'last name' then h.merge(last_name: f['cid'])
          when 'name' then h.merge(name: f['cid'])
          when 'phone number' then h.merge(phone_number: f['cid'])
          else h
          end
        end
      end

      first_name = last_name = ''
      if cids[:first_name] && cids[:last_name]
        first_name = the_settings[:fields][cids[:first_name]]
        last_name = the_settings[:fields][cids[:last_name]]
      elsif cids[:name]
        first_name, last_name = the_settings[:fields][cids[:name]].split ' '
      end

      contact = Plugins::FlexxPluginCrm::Contact.find_or_initialize_by(
        site_id: parent.site_id, email: the_settings[:fields][cids[:email]]
      ) do |c|
        c.site_id = parent.site_id
        c.first_name = first_name
        c.last_name = last_name
        c.email = the_settings[:fields][cids[:email]]
        c.source = 'website_form'
        c.cama_contact_form_id = id
      end

      if contact.new_record?
        contact.save
        TaskRecipeService.apply_recipes(contact: contact)
        Rails.logger.warn('RECIPES')
        AutomatedCampaignService.apply_campaigns(contact: contact)
      elsif contact.archived?
        contact.update sales_stage: :lead, unarchived_at: Time.current
      end

      update contact_id: contact.id

      return unless the_settings[:fields][cids[:phone_number]]

      phone = the_settings[:fields][cids[:phone_number]].gsub(/((?!^)\+|[^\+\d])/, '')

      phone = "+1#{phone}" if phone =~ /^\d/ && phone.size == 10

      Plugins::FlexxPluginCrm::Phonenumber.find_or_create_by(
        site_id: parent.site_id, number: phone
      ) { |p| p.contact_id = contact.id }
    end
  end

  user_class = (PluginRoutes.static_system_info['user_model'].presence || 'CamaleonCms::User').constantize

  user_class.class_eval do
    def initials
      result = if first_name.present? && last_name.present?
        "#{first_name[0]}#{last_name[0]}"
      else
        "#{username[0]}#{username[1]}"
      end

      result.upcase
    end

    def print_name
      result = [first_name, last_name].join(' ')
      result.blank? ? username : result
    end
  end
end
