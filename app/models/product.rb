
class Product < ApplicationRecord
  belongs_to :category

  has_one_attached :image do |attachable|
    attachable.variant :thumbnail, resize_to_fill: [300, 300]
    attachable.variant :medium, resize_to_limit: [600, 600]
    attachable.variant :large, resize_to_limit: [1000, 1000]
  end

  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true,
                    numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, presence: true,
                             numericality: {
                               only_integer: true,
                               greater_than_or_equal_to: 0
                             }

  validate :acceptable_image

  def self.ransackable_attributes(auth_object = nil)
    %w[id name description price stock_quantity category_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[category]
  end

  private

  def acceptable_image
    return unless image.attached?

    unless image.blob.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(:image, "must be a JPEG, PNG, or WebP image")
    end

    if image.blob.byte_size > 5.megabytes
      errors.add(:image, "must not exceed 5 MB")
    end
  end
end
