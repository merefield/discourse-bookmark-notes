import { hash } from "@ember/helper";
import {
  click,
  fillIn,
  render
} from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import pretender, { response } from "discourse/tests/helpers/create-pretender";
import BookmarkNoteEditor from "../../discourse/connectors/bookmark-modal-after-name/bookmark-note-editor";

module("Integration | Component | BookmarkNoteEditor", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    pretender.get("/emojis/search-aliases.json", () => response([]));
  });

  test("edits a note for a new bookmark", async function (assert) {
    const bookmark = {};

    await render(
      <template>
        <BookmarkNoteEditor @outletArgs={{hash bookmark=bookmark}} />
      </template>
    );
    await fillIn("#bookmark-note-raw", "A **private** note");

    assert
      .dom("label[for='bookmark-note-raw']")
      .hasText("Personal note", "labels the private note editor");
    assert.strictEqual(
      bookmark.bookmarkNoteRaw,
      "A **private** note",
      "copies the edited raw note to the bookmark form"
    );
  });

  test("renders the heading choices", async function (assert) {
    await render(
      <template>
        <BookmarkNoteEditor @outletArgs={{hash bookmark=(hash)}} />
      </template>
    );

    await click(".bookmark-note-editor button.heading");

    assert
      .dom('.toolbar-popup-menu-options .btn[data-name="heading-2"]')
      .exists("shows the heading choices");
  });

  test("loads and edits an existing note", async function (assert) {
    const bookmark = { id: 42 };
    pretender.get("/bookmark-notes/42.json", () =>
      response({ raw: "Existing note" })
    );

    await render(
      <template>
        <BookmarkNoteEditor @outletArgs={{hash bookmark=bookmark}} />
      </template>
    );

    assert
      .dom("#bookmark-note-raw")
      .hasValue("Existing note", "loads the owner's existing note");

    await fillIn("#bookmark-note-raw", "Updated note");

    assert.strictEqual(
      bookmark.bookmarkNoteRaw,
      "Updated note",
      "copies the updated raw note to the bookmark form"
    );
  });

  test("shows an error when an existing note cannot be loaded", async function (assert) {
    pretender.get("/bookmark-notes/42.json", () => response(500, {}));

    await render(
      <template>
        <BookmarkNoteEditor @outletArgs={{hash bookmark=(hash id=42)}} />
      </template>
    );

    assert
      .dom(".bookmark-note-editor .alert-error")
      .hasText(
        "Your personal note could not be loaded.",
        "explains that editing is unavailable"
      );
    assert
      .dom("#bookmark-note-raw")
      .doesNotExist("does not allow an unloaded note to be overwritten");
  });
});
