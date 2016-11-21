class Parcel < ApplicationRecord
  require 'CSV'

  geocoded_by :generated_address
  after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? }

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      parcel_hash = row.to_hash

      parcel = self.new
      parcel.address = parcel_hash["Address"]
      parcel.current_year_value = remove_dollar_symbol_and_convert_to_float(parcel_hash["Current Year Total Value"])
      parcel.previous_year_value = remove_dollar_symbol_and_convert_to_float(parcel_hash["Previous Year Total Value"])
      parcel.total_taxes = remove_dollar_symbol_and_convert_to_float(parcel_hash["Total Taxes"])

      parcel.save
    end
  end

  def generated_address
    self.address + ", Madison, WI"
  end


  private

  def self.remove_dollar_symbol_and_convert_to_float(value)
    value.gsub!('$','').to_f
  end
end