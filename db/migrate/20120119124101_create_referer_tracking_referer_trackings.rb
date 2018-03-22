class CreateRefererTrackingRefererTrackings < ActiveRecord::Migration[4.2]
  def change
    create_table :referer_trackings do |t|
      t.integer :trackable_id
      t.string :trackable_type
      t.text :referer_url
      t.text :first_url
      t.text :current_request_url
      t.text :current_request_referer_url
      t.string :user_agent
      t.string :ip
      t.string :session_id
      t.text :cookies_yaml

      t.timestamps
    end
  end
end
