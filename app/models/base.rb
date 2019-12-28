class Base < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  validates :assortment, length: { in: 2..50 }, allow_blank: true
end
