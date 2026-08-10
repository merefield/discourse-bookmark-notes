# frozen_string_literal: true

# name: discourse-bookmark-notes
# about: Adds private Markdown notes to bookmarks.
# version: 0.1.5
# authors: Discourse
# url: https://github.com/discourse/discourse-bookmark-notes

enabled_site_setting :discourse_bookmark_notes_enabled

add_admin_route(
  "admin.site_settings.categories.discourse_bookmark_notes",
  "discourse-bookmark-notes",
  use_new_show_route: true,
)

register_asset "stylesheets/common/bookmark-notes.scss"

module ::DiscourseBookmarkNotes
  PLUGIN_NAME = "discourse-bookmark-notes"

  def self.post_surface_enabled?
    SiteSetting.discourse_bookmark_notes_enabled &&
      DiscoursePluginRegistry.apply_modifier(
        :bookmark_notes_post_surface_enabled,
        SiteSetting.discourse_bookmark_notes_post_button_enabled,
      )
  end

  def self.serialize_post_note(bookmark)
    DiscoursePluginRegistry.apply_modifier(
      :bookmark_notes_post_payload,
      { bookmark_id: bookmark.id, title: bookmark.name },
      bookmark,
    )
  end
end

require_relative "lib/discourse_bookmark_notes/engine"
require_relative "lib/discourse_bookmark_notes/topic_view_extension"

after_initialize do
  reloadable_patch do
    ::Bookmark.has_one :bookmark_note,
                       class_name: "DiscourseBookmarkNotes::BookmarkNote",
                       dependent: :destroy
    ::TopicView.prepend(DiscourseBookmarkNotes::TopicViewExtension)
  end

  add_to_serializer(
    :post,
    :bookmark_personal_note,
    include_condition: -> do
      DiscourseBookmarkNotes.post_surface_enabled? && @topic_view.present? &&
        scope.current_user.present? && post_bookmark&.bookmark_note.present?
    end,
  ) { DiscourseBookmarkNotes.serialize_post_note(post_bookmark) }
end
