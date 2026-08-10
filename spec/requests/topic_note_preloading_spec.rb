# frozen_string_literal: true

RSpec.describe TopicView do
  fab!(:user)
  fab!(:topic)

  let(:bookmark_note_query_count) do
    lambda do |&block|
      track_sql_queries(&block).count { |sql| sql.include?('FROM "bookmark_notes"') }
    end
  end

  before do
    SiteSetting.discourse_bookmark_notes_post_button_enabled = true
    if SiteSetting.respond_to?(:discourse_bookmark_notes_pro_post_panel_enabled=)
      SiteSetting.discourse_bookmark_notes_pro_post_panel_enabled = false
    end
    sign_in(user)
  end

  it "serializes a note for its owner but not a bookmark without a note" do
    post_with_note = Fabricate(:post, topic:)
    bookmark_with_note =
      Fabricate(:bookmark, user:, bookmarkable: post_with_note, name: "Meeting research")
    Fabricate(:bookmark_note, bookmark: bookmark_with_note, raw: "Private note")

    post_without_note = Fabricate(:post, topic:)
    Fabricate(:bookmark, user:, bookmarkable: post_without_note)

    get "/t/#{topic.id}.json"

    posts = response.parsed_body.dig("post_stream", "posts")
    serialized_note = posts.find { |post| post["id"] == post_with_note.id }
    serialized_without_note = posts.find { |post| post["id"] == post_without_note.id }

    expect(serialized_note["bookmark_personal_note"]).to eq(
      "bookmark_id" => bookmark_with_note.id,
      "title" => "Meeting research",
    )
    expect(serialized_without_note).not_to have_key("bookmark_personal_note")
  end

  it "preloads personal notes for bookmarked posts without N+1 queries" do
    first_post = Fabricate(:post, topic:)
    first_bookmark = Fabricate(:bookmark, user:, bookmarkable: first_post)
    Fabricate(:bookmark_note, bookmark: first_bookmark, raw: "First note")

    queries_for_one = bookmark_note_query_count.call { get "/t/#{topic.id}.json" }

    2.times do |index|
      post = Fabricate(:post, topic:)
      bookmark = Fabricate(:bookmark, user:, bookmarkable: post)
      Fabricate(:bookmark_note, bookmark:, raw: "Additional note #{index}")
    end

    queries_for_three = bookmark_note_query_count.call { get "/t/#{topic.id}.json" }

    expect(queries_for_three).to eq(queries_for_one)
    expect(queries_for_three).to eq(1)
  end
end
