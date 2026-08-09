# frozen_string_literal: true

module PageObjects
  module Modals
    class BookmarkNote < PageObjects::Modals::Bookmark
      def fill_note(raw)
        fill_in("bookmark-note-raw", with: raw)
      end

      def save_with_enter_from_name
        find_field("bookmark-name").send_keys(:enter)
      end

      def append_note_line(raw)
        find_field("bookmark-note-raw").send_keys(:enter, raw)
      end

      def type_rich_note(*keys)
        find(".bookmark-note-editor .d-editor-input.ProseMirror").send_keys(*keys)
      end

      def clear_note
        fill_note("")
      end

      def has_note_editor?
        has_css?(".bookmark-note-editor .d-editor") &&
          has_field?("bookmark-note-raw")
      end

      def has_rich_note_editor?
        has_css?(".bookmark-note-editor .d-editor-input.ProseMirror")
      end

      def has_rich_note_paragraphs?(*texts)
        texts.all? do |text|
          has_css?(".bookmark-note-editor .ProseMirror p", text:)
        end
      end

      def has_note?(raw)
        has_field?("bookmark-note-raw", with: raw)
      end

      def has_no_note?(raw)
        has_no_field?("bookmark-note-raw", with: raw)
      end

      def has_empty_note?
        has_note?("")
      end

      def has_bookmark_title?(title)
        has_field?("bookmark-name", with: title)
      end

      def has_formatted_preview?(text)
        has_css?(".bookmark-note-editor .d-editor-preview strong", text: text)
      end

      def open_heading_menu
        find(".bookmark-note-editor button.heading").click
        self
      end

      def has_heading_options?
        has_css?(".toolbar-popup-menu-options .dropdown-menu__item", minimum: 6)
      end

      def select_heading(level)
        find(
          ".toolbar-popup-menu-options .btn[data-name='heading-#{level}']"
        ).click
      end

      def has_heading_preview?(level, text)
        has_css?(
          ".bookmark-note-editor .d-editor-preview h#{level}",
          text: text
        )
      end

      def has_existing_reminder?
        has_css?(".existing-reminder-at-alert")
      end
    end
  end
end
