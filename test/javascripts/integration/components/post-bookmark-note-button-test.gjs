import { render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import PostBookmarkNoteButton from "../../discourse/components/post-bookmark-note-button";

module("Integration | Component | PostBookmarkNoteButton", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.post = {
      id: 1,
      bookmark_personal_note: { bookmark_id: 2, title: "Meeting research" },
    };
    this.siteSettings.discourse_bookmark_notes_post_button_enabled = true;
    this.siteSettings.discourse_bookmark_notes_pro_post_panel_enabled = true;
  });

  test("hides the button when the Pro post panel is active", async function (assert) {
    this.siteSettings.discourse_bookmark_notes_pro_ext_enabled = true;

    await render(
      <template><PostBookmarkNoteButton @post={{this.post}} /></template>
    );

    assert
      .dom(".post-bookmark-note-button")
      .doesNotExist("the Pro post panel takes precedence");
  });

  test("shows the button when the Pro plugin is disabled", async function (assert) {
    this.siteSettings.discourse_bookmark_notes_pro_ext_enabled = false;

    await render(
      <template><PostBookmarkNoteButton @post={{this.post}} /></template>
    );

    assert
      .dom(".post-bookmark-note-button")
      .exists("the base button remains available");
  });
});
