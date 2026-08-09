# frozen_string_literal: true

DiscourseBookmarkNotes::Engine.routes.draw do
  get "/:bookmark_id" => "bookmark_notes#show"
  put "/:bookmark_id" => "bookmark_notes#update"
end

Discourse::Application.routes.draw do
  mount DiscourseBookmarkNotes::Engine, at: "/bookmark-notes"
end
