class CanadianSalesTax
  PROVINCES = {
    "Alberta" => "AB",
    "British Columbia" => "BC",
    "Manitoba" => "MB",
    "New Brunswick" => "NB",
    "Newfoundland and Labrador" => "NL",
    "Nova Scotia" => "NS",
    "Northwest Territories" => "NT",
    "Nunavut" => "NU",
    "Ontario" => "ON",
    "Prince Edward Island" => "PE",
    "Quebec" => "QC",
    "Saskatchewan" => "SK",
    "Yukon" => "YT"
  }.freeze

  RATES = {
    "AB" => { gst: "0.05", pst: "0", hst: "0" },
    "BC" => { gst: "0.05", pst: "0.07", hst: "0" },
    "MB" => { gst: "0.05", pst: "0.07", hst: "0" },
    "NB" => { gst: "0", pst: "0", hst: "0.15" },
    "NL" => { gst: "0", pst: "0", hst: "0.15" },
    "NS" => { gst: "0", pst: "0", hst: "0.14" },
    "NT" => { gst: "0.05", pst: "0", hst: "0" },
    "NU" => { gst: "0.05", pst: "0", hst: "0" },
    "ON" => { gst: "0", pst: "0", hst: "0.13" },
    "PE" => { gst: "0", pst: "0", hst: "0.15" },
    "QC" => { gst: "0.05", pst: "0.09975", hst: "0" },
    "SK" => { gst: "0.05", pst: "0.06", hst: "0" },
    "YT" => { gst: "0.05", pst: "0", hst: "0" }
  }.freeze

  def initialize(subtotal:, province:)
    @subtotal = BigDecimal(subtotal.to_s)
    @province = province.to_s

    raise ArgumentError, "Invalid province" unless RATES.key?(@province)
  end

  def gst_amount
    calculate(:gst)
  end

  def pst_amount
    calculate(:pst)
  end

  def hst_amount
    calculate(:hst)
  end

  def total
    @subtotal + gst_amount + pst_amount + hst_amount
  end

  private

  def calculate(type)
    rate = BigDecimal(RATES.fetch(@province).fetch(type))
    (@subtotal * rate).round(2)
  end
end