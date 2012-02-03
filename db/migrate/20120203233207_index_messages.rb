class IndexMessages < ActiveRecord::Migration
  def change
    add_index :messages, [:channel, :when]
  end
end
