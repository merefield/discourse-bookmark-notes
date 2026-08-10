# frozen_string_literal: true

Fabricator(:bookmark_note, class_name: "DiscourseBookmarkNotes::BookmarkNote") do
  bookmark
  raw "A **private** note"
end
