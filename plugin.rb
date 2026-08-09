# frozen_string_literal: true

# name: discourse-bookmark-notes
# about: Adds private Markdown notes to bookmarks.
# version: 0.1.3
# authors: Discourse
# url: https://github.com/discourse/discourse-bookmark-notes

enabled_site_setting :discourse_bookmark_notes_enabled

register_asset "stylesheets/common/bookmark-notes.scss"

module ::DiscourseBookmarkNotes
  PLUGIN_NAME = "discourse-bookmark-notes"
end

require_relative "lib/discourse_bookmark_notes/engine"

after_initialize do
  reloadable_patch do
    ::Bookmark.has_one :bookmark_note,
                       class_name: "DiscourseBookmarkNotes::BookmarkNote",
                       dependent: :destroy
  end
end
