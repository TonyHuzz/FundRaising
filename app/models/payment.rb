class Payment < ApplicationRecord
  belongs_to :pledge

  enum status: [:not_paid_yet, :paid, :canceled_before_paid, :waiting_for_refund, :canceled_and_refunded]

  enum transaction_service_provider: [:mpg]

  enum payment_type: [:credit_card, :cvs, :bar_code, :atm]

  validates :merchant_order_no, presence: true

  validates_numericality_of :end_price, greater_than_or_equal_to: 0

end
