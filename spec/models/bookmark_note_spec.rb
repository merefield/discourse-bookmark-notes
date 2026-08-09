# frozen_string_literal: true

RSpec.describe DiscourseBookmarkNotes::BookmarkNote do
  fab!(:bookmark)

  it "cooks Markdown when the raw note changes" do
    note =
      Fabricate(:bookmark_note, bookmark: bookmark, raw: "A **private** note")

    expect(note.cooked).to include("<strong>private</strong>")
    expect(note.cooked_version).to eq(described_class::COOKED_VERSION)
  end

  it "limits the raw note to the maximum post length" do
    SiteSetting.max_post_length = 10
    note = described_class.new(bookmark: bookmark, raw: "a" * 11)

    expect(note).not_to be_valid
    expect(note.errors[:raw]).to be_present
  end

  it "allows only one note for each bookmark" do
    Fabricate(:bookmark_note, bookmark: bookmark)
    duplicate = described_class.new(bookmark: bookmark, raw: "Another note")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:bookmark_id]).to be_present
  end

  it "is deleted when its bookmark is deleted without callbacks" do
    note = Fabricate(:bookmark_note, bookmark: bookmark)

    bookmark.delete

    expect(described_class.exists?(note.id)).to eq(false)
  end
end
