module StringManipulation

  DIACRITICS = [*0x1DC0..0x1DFF, *0x0300..0x036F, *0xFE20..0xFE2F].pack('U*')

  def self.remove_accents(str)
    str.unicode_normalize(:nfd).tr(DIACRITICS, '').unicode_normalize(:nfc)
  end

  def self.remove_special_chars(str)
    str.gsub(/[^a-zA-Z0-9\s]/, '')
  end

end