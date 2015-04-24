class LogAndStatus < ActiveRecord::Migration
  def change
    add_column :referer_trackings, :log, :text
    add_column :referer_trackings, :status, :string
  end
end
