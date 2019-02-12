class AddColumnsToPlaces < ActiveRecord::Migration[5.2]
  def change
    add_column :places, :type_filter, :text, array: true, default: []
    add_column :places, :ambience_filter, :text, array: true, default: []
    add_column :places, :has_offers, :boolean
    add_column :places, :is_payment_available, :boolean
    add_column :places, :is_booking_available, :boolean
    add_column :places, :is_favorited, :boolean
    add_column :places, :picture_url, :string
  end
end
