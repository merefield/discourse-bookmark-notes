# frozen_string_literal: true

module PageObjects
  module Components
    class PostBookmarkNoteButton < PageObjects::Components::Base
      def initialize(post)
        @selector = "#post_#{post.post_number} .post-bookmark-note-button"
      end

      def visible?
        has_css?(@selector)
      end

      def not_visible?
        has_no_css?(@selector)
      end

      def has_label?(label)
        has_css?("#{@selector} .post-bookmark-note-button__trigger", exact_text: label)
      end

      def open
        find("#{@selector} .post-bookmark-note-button__trigger").click
        self
      end
    end
  end
end
