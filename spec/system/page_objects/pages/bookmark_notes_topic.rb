# frozen_string_literal: true

module PageObjects
  module Pages
    class BookmarkNotesTopic < PageObjects::Pages::Topic
      def expand_post_actions_if_needed(post)
        post_element = post_by_number(post)
        if post_element.has_css?(".show-more-actions", wait: 0)
          post_element.find(".show-more-actions").click
        end
        self
      end
    end
  end
end
