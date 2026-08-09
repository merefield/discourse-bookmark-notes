# frozen_string_literal: true

class CreateBookmarkNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :bookmark_notes do |t|
      t.bigint :bookmark_id, null: false
      t.text :raw, null: false
      t.text :cooked, null: false
      t.integer :cooked_version, null: false
      t.timestamps null: false
    end

    add_index :bookmark_notes, :bookmark_id, unique: true
    add_foreign_key :bookmark_notes, :bookmarks, on_delete: :cascade
  end
end
