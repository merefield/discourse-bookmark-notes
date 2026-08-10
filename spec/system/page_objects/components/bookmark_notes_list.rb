# frozen_string_literal: true

module PageObjects
  module Components
    class BookmarkNotesList < PageObjects::Components::BookmarkList
      def edit_bookmark(topic)
        row = bookmark_row(topic)
        row.find(".bookmark-actions-dropdown .select-kit-header").click
        row.find(".bookmark-actions-dropdown .select-kit-row[data-value='edit']").click
        self
      end
    end
  end
end
