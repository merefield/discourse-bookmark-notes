# frozen_string_literal: true

RSpec.describe DiscourseBookmarkNotes::BookmarkNotesController do
  fab!(:user)
  fab!(:other_user, :user)
  fab!(:admin)
  fab!(:post)
  fab!(:bookmark) { Fabricate(:bookmark, user: user, bookmarkable: post) }

  before { SiteSetting.discourse_bookmark_notes_enabled = true }

  describe "#show" do
    it "returns the owner's raw note" do
      note = Fabricate(:bookmark_note, bookmark: bookmark)
      sign_in(user)

      get "/bookmark-notes/#{bookmark.id}.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body["raw"]).to eq(note.raw)
    end

    it "returns an empty raw value when the bookmark has no note" do
      sign_in(user)

      get "/bookmark-notes/#{bookmark.id}.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body).to eq("raw" => "")
    end

    it "does not expose a note to another user or an administrator" do
      note = Fabricate(:bookmark_note, bookmark: bookmark)

      [other_user, admin].each do |viewer|
        sign_in(viewer)
        get "/bookmark-notes/#{bookmark.id}.json"

        expect(response.status).to eq(404)
        expect(response.body).not_to include(note.raw)
      end
    end
  end

  describe "#update" do
    before { sign_in(user) }

    it "creates and updates a Markdown note" do
      put "/bookmark-notes/#{bookmark.id}.json", params: { raw: "First **note**" }

      expect(response.status).to eq(204)
      note = bookmark.reload.bookmark_note
      expect(note.raw).to eq("First **note**")
      expect(note.cooked).to include("<strong>note</strong>")

      put "/bookmark-notes/#{bookmark.id}.json", params: { raw: "Updated note" }

      expect(response.status).to eq(204)
      expect(note.reload.raw).to eq("Updated note")
    end

    it "deletes the note when the raw value is blank" do
      note = Fabricate(:bookmark_note, bookmark: bookmark)

      put "/bookmark-notes/#{bookmark.id}.json", params: { raw: "" }

      expect(response.status).to eq(204)
      expect(DiscourseBookmarkNotes::BookmarkNote.exists?(note.id)).to eq(false)
    end

    it "keeps notes independent for users who bookmark the same post" do
      other_bookmark = Fabricate(:bookmark, user: other_user, bookmarkable: post)

      put "/bookmark-notes/#{bookmark.id}.json", params: { raw: "User note" }
      sign_in(other_user)
      put "/bookmark-notes/#{other_bookmark.id}.json", params: { raw: "Other note" }

      expect(response.status).to eq(204)
      expect(bookmark.reload.bookmark_note.raw).to eq("User note")
      expect(other_bookmark.reload.bookmark_note.raw).to eq("Other note")
    end

    it "does not allow another user to change the note" do
      note = Fabricate(:bookmark_note, bookmark: bookmark)
      sign_in(other_user)

      put "/bookmark-notes/#{bookmark.id}.json", params: { raw: "Changed" }

      expect(response.status).to eq(404)
      expect(note.reload.raw).not_to eq("Changed")
    end
  end
end
