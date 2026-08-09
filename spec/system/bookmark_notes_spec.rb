# frozen_string_literal: true

RSpec.describe "Bookmark personal notes" do
  fab!(:current_user) do
    Fabricate(
      :user,
      refresh_auto_groups: true,
      uploaded_avatar: Fabricate(:image_upload)
    )
  end
  fab!(:other_user) do
    Fabricate(
      :user,
      refresh_auto_groups: true,
      uploaded_avatar: Fabricate(:image_upload)
    )
  end
  fab!(:topic)
  fab!(:post) do
    Fabricate(
      :post,
      topic:,
      user: current_user,
      raw: "Research material for the team"
    )
  end

  let(:topic_page) { PageObjects::Pages::BookmarkNotesTopic.new }
  let(:bookmarks_page) { PageObjects::Pages::UserActivityBookmarks.new }
  let(:bookmark_menu) { PageObjects::Components::BookmarkMenu.new }
  let(:bookmark_list) { PageObjects::Components::BookmarkNotesList.new }
  let(:bookmark_modal) { PageObjects::Modals::BookmarkNote.new }

  before do
    SiteSetting.discourse_bookmark_notes_enabled = true
    current_user.user_option.update!(timezone: "Europe/London")
    other_user.user_option.update!(timezone: "Europe/London")
  end

  it "creates, updates, and removes a Markdown note without losing the bookmark reminder" do
    sign_in(current_user)
    visit_topic_and_open_bookmark_menu
    bookmark_menu.click_menu_option("custom")

    expect(bookmark_modal).to be_open
    expect(bookmark_modal).to have_note_editor

    bookmark_modal.fill_name("Research for next meeting")
    bookmark_modal.fill_note("Project X")
    bookmark_modal.append_note_line("Follow up")

    expect(bookmark_modal).to be_open
    expect(bookmark_modal).to have_note("Project X\nFollow up")

    bookmark_modal.fill_note("Project X")
    bookmark_modal.open_heading_menu

    expect(bookmark_modal).to have_heading_options

    bookmark_modal.select_heading(2)

    expect(bookmark_modal).to have_heading_preview(2, "Heading")

    bookmark_modal.fill_note("## Project X")

    bookmark_modal.select_preset_reminder(:tomorrow)

    expect(topic_page).to have_post_bookmarked(post, with_reminder: true)

    open_existing_bookmark

    expect(bookmark_modal).to have_bookmark_title("Research for next meeting")
    expect(bookmark_modal).to have_note("## Project X")
    expect(bookmark_modal).to have_existing_reminder

    bookmark_modal.fill_note("Follow up with **Sarah** about the results.")
    bookmark_modal.save
    page.refresh
    open_existing_bookmark

    expect(bookmark_modal).to have_note(
      "Follow up with **Sarah** about the results."
    )
    expect(bookmark_modal).to have_existing_reminder

    bookmark_modal.clear_note
    bookmark_modal.save
    page.refresh
    open_existing_bookmark

    expect(bookmark_modal).to have_empty_note
    expect(bookmark_modal).to have_existing_reminder
  end

  it "edits an existing personal note from the bookmarks list" do
    bookmark =
      Fabricate(
        :bookmark,
        user: current_user,
        bookmarkable: post,
        name: "Reading notes"
      )
    Fabricate(:bookmark_note, bookmark:, raw: "Initial **private** note")
    Fabricate(:topic_user, user: current_user, topic:)
    sign_in(current_user)

    bookmarks_page.visit(current_user)
    bookmark_list.edit_bookmark(topic)

    expect(bookmark_modal).to have_bookmark_title("Reading notes")
    expect(bookmark_modal).to have_note("Initial **private** note")

    bookmark_modal.fill_note("Updated from the **bookmarks list**")
    bookmark_modal.save
    page.refresh
    bookmark_list.edit_bookmark(topic)

    expect(bookmark_modal).to have_note("Updated from the **bookmarks list**")
  end

  it "keeps Enter inside the rich text note editor" do
    current_user.user_option.update!(
      composition_mode: UserOption.composition_mode_types[:rich]
    )
    sign_in(current_user)
    visit_topic_and_open_bookmark_menu
    bookmark_menu.click_menu_option("custom")

    expect(bookmark_modal).to be_open
    expect(bookmark_modal).to have_rich_note_editor

    bookmark_modal.type_rich_note("First line", :enter, "Second line")

    expect(bookmark_modal).to be_open
    expect(bookmark_modal).to have_rich_note_paragraphs(
      "First line",
      "Second line"
    )

    bookmark_modal.fill_name("Rich editor note")
    bookmark_modal.save_with_enter_from_name

    expect(bookmark_modal).to be_closed
    expect(topic_page).to have_post_bookmarked(post)
  end

  it "shows each user only their own note on the same post" do
    current_user_bookmark =
      Fabricate(:bookmark, user: current_user, bookmarkable: post)
    other_user_bookmark =
      Fabricate(:bookmark, user: other_user, bookmarkable: post)
    Fabricate(
      :bookmark_note,
      bookmark: current_user_bookmark,
      raw: "Current user's private note"
    )
    Fabricate(
      :bookmark_note,
      bookmark: other_user_bookmark,
      raw: "Other user's private note"
    )

    sign_in(current_user)
    topic_page.visit_topic(topic)
    open_existing_bookmark

    expect(bookmark_modal).to have_note("Current user's private note")
    expect(bookmark_modal).to have_no_note("Other user's private note")

    sign_in(other_user)
    topic_page.visit_topic(topic)
    open_existing_bookmark

    expect(bookmark_modal).to have_note("Other user's private note")
    expect(bookmark_modal).to have_no_note("Current user's private note")
  end

  private

  def visit_topic_and_open_bookmark_menu
    topic_page.visit_topic(topic)
    topic_page.expand_post_actions_if_needed(post)
    topic_page.click_post_action_button(post, :bookmark)
  end

  def open_existing_bookmark
    topic_page.expand_post_actions_if_needed(post)
    topic_page.click_post_action_button(post, :bookmark)
    bookmark_menu.click_menu_option("edit")
  end
end
