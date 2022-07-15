class AddNoCreditToServices < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :no_credit, :boolean, default: false
  end
end
