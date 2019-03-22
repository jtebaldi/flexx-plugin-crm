require 'csv'

class ImportContactsService

  private_class_method :new

  def initialize(csv_file, site, user)
    @csv_file = csv_file
    @site = site
    @user = user
  end

  def self.import_csv(file:, site:, user:)
    new(file, site, user).import_csv
  end

  def import_csv
    CSV.foreach(@csv_file, headers: true) do |row|
      if row['email'].present?
        find_or_create_by_email row
      else
        find_or_create_by_phone row
      end
    end
  end

  private

  def find_or_create_by_email(row)
    contact = @site.contacts.find_or_create_by email: row['email'] do |c|
      c.attributes = row.to_hash.except('phonenumber')
      c.birthday = Time.strptime row['birthday'], '%Y/%m/%d' if row['birthday'].present?
      c.created_by = @user.id
    end

    if row['phonenumber'].present?
      number = if row['phonenumber'] !~ /^\+/ && row['phonenumber'].length == 10
        '+1' + row['phonenumber']
      else
        row['phonenumber']
      end

      contact.phonenumbers.find_or_create_by number: number do |p|
        p.site = @site
      end
    end
  end

  def find_or_create_by_phone(row)
    number = if row['phonenumber'] !~ /^\+/ && row['phonenumber'].length == 10
      '+1' + row['phonenumber']
    else
      row['phonenumber']
    end

    if @site.phonenumbers.find_by(number: number).blank?
      new_contact = @site.contacts.new(row.to_hash.except('phonenumber'))
      new_contact.birthday = Time.strptime row['birthday'], '%Y/%m/%d' if row['birthday'].present?
      new_contact.created_by = @user.id

      new_contact.save!(validate: false)

      new_contact.phonenumbers.create!(number: number, site_id: @site.id)
    end
  end
end
