# frozen_string_literal: true

require 'string/similarity'

class InvoiceItem < ApplicationRecord
  belongs_to :invoice

  # DB METHODS
  scope :from_invoice, ->(invoice_id) { where(invoice_id:) }

  # CLASSIC METHODS
  def bio?(description)
    bio_terms = [' BIO', ' AB']
    bio_terms.any? { |term| description.include?(term) }
  end

  def origin?(description)
    cleaned_description_words = clean_description(description)
    cleaned_description_words.each do |word|
      origin = ISO3166::Country.find_country_by_any_name(word) || ISO3166::Country.find_country_by_alpha3(word)
      return origin if origin
    end
    nil
  end

  def agribalyse(description, synthesis)
    result = {}
    cleaned_description_words = clean_description(description)
    return result.to_json if cleaned_description_words.size < 2

    product_name_shorted = cleaned_description_words[0..1].join(' ')
    synthesis.each do |row|
      next if row.nil?

      product_french_name = row[4]&.value
      next if product_french_name.blank?

      similarity_score = String::Similarity.levenshtein_distance(product_name_shorted, product_french_name)
      next unless similarity_score <= 5

      result = {
        agribalyse_reference: true,
        agribalyse_category: row[2]&.value,
        agribalyse_subcategory: row[3]&.value
      }
      break
    end
    result.to_json
  end

  private

  def clean_description(description)
    description_without_special_chars = StringManipulation.remove_special_chars(description)
    description_cleaned = StringManipulation.remove_accents(description_without_special_chars)
    description_cleaned.split(' ')
  end
end
