# frozen_string_literal: true

module DiscourseBookmarkNotes
  class BookmarkNotesController < ::ApplicationController
    requires_plugin PLUGIN_NAME
    requires_login

    def show
      render json: { raw: bookmark.bookmark_note&.raw.to_s }
    end

    def update
      raw = permitted_params[:raw]
      raise ActionController::ParameterMissing.new(:raw) if raw.nil?

      if raw.blank?
        bookmark.bookmark_note&.destroy!
        return head :no_content
      end

      note = bookmark.bookmark_note || bookmark.build_bookmark_note

      if note.update(raw: raw)
        head :no_content
      else
        render json: failed_json.merge(errors: note.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    private

    def bookmark
      @bookmark ||= current_user.bookmarks.find_by(id: params[:bookmark_id])
      raise Discourse::NotFound if @bookmark.blank?

      @bookmark
    end

    def permitted_params
      params.permit(:raw)
    end
  end
end
