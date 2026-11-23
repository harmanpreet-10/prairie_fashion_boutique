
class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy

  validates :customer_name, presence: true
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :shipping_address, presence: true
  validates :province, inclusion: { in: CanadianSalesTax::RATES.keys }

  validates :subtotal, :total,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :gst_amount, :pst_amount, :hst_amount,
            numericality: { greater_than_or_equal_to: 0 }

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id customer_name email shipping_address province
      subtotal gst_amount pst_amount hst_amount total
      created_at updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[order_items]
  end
end
