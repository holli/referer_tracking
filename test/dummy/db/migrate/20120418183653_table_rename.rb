class TableRename < ActiveRecord::Migration
  def up
    rename_table :referer_tracking_referer_trackings, :referer_trackings
    add_column :referer_trackings, :request_added, :string
    add_column :referer_trackings, :session_added, :string
  end

  def down
    rename_table :referer_trackings, :referer_tracking_referer_trackings
  end
end
