require 'string/similarity'

class InvoiceItem < ApplicationRecord
  belongs_to :invoice

  # DB METHODS
  def self.get_invoice_items_from_invoice(invoice_id)
    where(invoice_id: invoice_id)
  end

  # CLASSIC METHODS
  def is_bio(description)
    # Prefix white space to prevent label being in real item name
    # CF : SIROP ERABLE MAPLE J0E FL/ 1L that shouldnt return true with AB
    is_bio = false
    bio_terms = [" BIO", " AB"]
    bio_terms.each do |term|
      if description.include?(term)
        is_bio = true
      end
    end
    is_bio
  end

  def has_origin(description)
    origin = nil
    # Remove Special Chars and Accents
    description_without_special_chars = StringManipulation.remove_special_chars(description)
    description_cleaned = StringManipulation.remove_accents(description_without_special_chars)
    # Check every word in item description to matches with a country
    cleaned_description_words = description_cleaned.split(" ")
    # Recursively look for a match with complete country name, alpha2 and alpha3 code
    cleaned_description_words.each do |word|
      # Removed usage of alpha2
      # Too much confusion with gr => greece, kg => kyrgyzstan, au => austria, de => germany etc
        origin = ISO3166::Country.find_country_by_any_name(word)
        if origin.nil?
          origin = ISO3166::Country.find_country_by_alpha3(word)
        end
      end
    origin
  end

  def has_agribalyse_reference(description, synthesis)
    result = {}
    # Remove Special Chars and Accents
    description_without_special_chars = StringManipulation.remove_special_chars(description)
    description_cleaned = StringManipulation.remove_accents(description_without_special_chars)
    # Removes Accents
    cleaned_description_words = description_cleaned.split(" ")
    # Try to find a match between the invoice item description and agribalyse product fr names
    synthesis.each do |row|
      next if row.nil?
      # Picking product french name from Agribalyse DB which means column index 4
      product_french_name = row[4]
      if product_french_name && !product_french_name.value.blank? && description && !description.blank?
        if cleaned_description_words[0] && cleaned_description_words[1]
          # Shorting product french name to first two words to keep a efficient comparison with Agribalyse later
          product_name_shorted = cleaned_description_words[0]+' '+cleaned_description_words[1]
          similarity_score = String::Similarity.levenshtein_distance(product_name_shorted, product_french_name.value)
          # Similarity score is <= 5 means french product is find in Agribalyse, we break and return
          if similarity_score <= 5
            result = {
              agribalyse_reference: true,
              agribalyse_category: row[2].value,
              agribalyse_subcategory: row[3].value
            }
            break
          end
        end
      end
    end
    result.to_json
  end

end
