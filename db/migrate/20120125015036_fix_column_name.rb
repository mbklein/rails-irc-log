class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :messages, :where, :channel
  end
end
