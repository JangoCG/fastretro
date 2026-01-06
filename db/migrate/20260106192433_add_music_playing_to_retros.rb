class AddMusicPlayingToRetros < ActiveRecord::Migration[8.1]
  def change
    add_column :retros, :music_playing, :boolean, default: false, null: false
  end
end
