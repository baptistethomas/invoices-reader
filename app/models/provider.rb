class Provider < ApplicationRecord
  # Relations
  has_many :invoice, dependent: :destroy

  # Uniqueness between names and vat numbers to prevent duplicate providers
  validates_uniqueness_of :names, :scope => :vat_numbers

  # DB METHODS
  def self.get_provider_by_one_of_names(name)
    # Return first result matching with name used in array names
    result = Provider.where("? = ANY(names)", name)
    result.first
  end

end
