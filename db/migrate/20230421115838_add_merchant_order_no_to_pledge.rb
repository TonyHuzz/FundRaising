class AddMerchantOrderNoToPledge < ActiveRecord::Migration[5.2]
  def change
    add_column :pledges, :merchantOrderNo, :string
  end
end
