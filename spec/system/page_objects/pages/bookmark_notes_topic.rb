# frozen_string_literal: true

module PageObjects
  module Pages
    class BookmarkNotesTopic < PageObjects::Pages::Topic
      def open_bookmark(post)
        expand_post_actions_if_needed(post)
        click_post_action_button(post, :bookmark)
        self
      end

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
