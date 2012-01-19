class CreateRefererTrackingRefererTrackings < ActiveRecord::Migration
  def change
    create_table :referer_tracking_referer_trackings do |t|
      t.integer :trackable_id
      t.string :trackable_type
      t.text :referer_url
      t.text :first_url
      t.string :user_agent

      t.timestamps
    end
  end
end
