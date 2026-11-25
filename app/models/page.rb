
class Page < ApplicationRecord
  validates :title, presence: true,
                    length: { maximum: 100 }

  validates :slug, presence: true,
                   uniqueness: true,
                   format: {
                     with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
                   }

  validates :content, presence: true,
                      length: { maximum: 10000 }

  def self.ransackable_attributes(auth_object = nil)
    %w[id title slug content created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
