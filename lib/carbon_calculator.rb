module CarbonCalculator

  # No real infos on specs about compare origin,
  # We suppose that we compare product origin with France
  COMPARE_ORIGIN = 'FRANCE'
  SAME_COUNTRY_EQCO2_BY_KG = 0.2
  SAME_WORLD_REGION_EQCO2_BY_KG = 0.15
  NOT_SAME_WORLD_REGION_EQCO2_BY_KG = 0.3
  UNKNOWN_ORIGIN_EQCO2_BY_KG = 0.2

  def self.get_eqco2_by_item_origin(origin_item, weight)

    # Get Countries info for compare and origin
    compare_country = ISO3166::Country.find_country_by_any_name(COMPARE_ORIGIN)
    origin_country = ISO3166::Country.find_country_by_any_name(origin_item)

    # Prepair default value for eqco2
    eqco2_by_kg = UNKNOWN_ORIGIN_EQCO2_BY_KG

    # We have the origin we apply rules
    if !origin_item.nil?
      if compare_country.alpha3 == origin_country.alpha3
        eqco2_by_kg = SAME_COUNTRY_EQCO2_BY_KG
      elsif compare_country.world_region == origin_country.world_region
        eqco2_by_kg = SAME_WORLD_REGION_EQCO2_BY_KG
      elsif compare_country.world_region != origin_country.world_region
        eqco2_by_kg = NOT_SAME_WORLD_REGION_EQCO2_BY_KG
      end
    # Origin being nil means that we dont know origin, so we apply appropriate constant
    else
      eqco2_by_kg = UNKNOWN_ORIGIN_EQCO2_BY_KG
    end

    # Eqco2kg by the weight in kg
    eqco2_by_kg * weight
  end

end