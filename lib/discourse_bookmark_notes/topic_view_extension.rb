# frozen_string_literal: true

module DiscourseBookmarkNotes
  module TopicViewExtension
    def bookmarks
      bookmarks = super

      if DiscourseBookmarkNotes.post_surface_enabled? && bookmarks.present? &&
           !instance_variable_defined?(:@bookmark_notes_notes_preloaded)
        ActiveRecord::Associations::Preloader.new(
          records: bookmarks,
          associations: :bookmark_note,
        ).call
        @bookmark_notes_notes_preloaded = true
      end

      bookmarks
    end
  end
end
