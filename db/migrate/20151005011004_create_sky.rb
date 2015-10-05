class CreateSky < ActiveRecord::Migration
  def change
    create_table :skies do |t|
      t.string :colors, array: true, default: []
      t.timestamps
    end

    add_attachment :skies, :image
  end
end
