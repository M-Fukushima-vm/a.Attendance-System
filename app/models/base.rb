class Base < ApplicationRecord
  validates :number, uniqueness: true, length: { maximum: 50 }
  validates :name, presence: true, length: { maximum: 50 }, uniqueness: true
  validates :assortment, length: { in: 2..50 }, allow_blank: true
end
