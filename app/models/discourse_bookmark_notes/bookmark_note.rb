# frozen_string_literal: true

module DiscourseBookmarkNotes
  class BookmarkNote < ::ActiveRecord::Base
    COOKED_VERSION = 1

    self.table_name = "bookmark_notes"

    belongs_to :bookmark

    before_validation :cook_raw, if: :will_save_change_to_raw?

    validates :bookmark_id, uniqueness: true
    validates :raw, :cooked, presence: true
    validates :cooked_version, presence: true
    validate :raw_length_within_limit

    private

    def cook_raw
      return if raw.blank?

      self.cooked = PrettyText.cook(raw, user_id: bookmark&.user_id)
      self.cooked_version = COOKED_VERSION
    end

    def raw_length_within_limit
      return if raw.blank? || raw.length <= SiteSetting.max_post_length

      errors.add(:raw, :too_long, count: SiteSetting.max_post_length)
    end
  end
end

# == Schema Information
#
# Table name: bookmark_notes
#
#  id             :bigint           not null, primary key
#  cooked         :text             not null
#  cooked_version :integer          not null
#  raw            :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  bookmark_id    :bigint           not null
#
# Indexes
#
#  index_bookmark_notes_on_bookmark_id  (bookmark_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (bookmark_id => bookmarks.id) ON DELETE => cascade
#
