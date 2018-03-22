class LogAndStatus < ActiveRecord::Migration[4.2]
  def change
    add_column :referer_trackings, :log, :text
    add_column :referer_trackings, :status, :string
  end
end
