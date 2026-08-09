import { setupTest } from "ember-qunit";
import { module, test } from "qunit";
import pretender, { response } from "discourse/tests/helpers/create-pretender";
import {
  loadBookmarkNote,
  saveBookmarkNote,
} from "../../discourse/lib/bookmark-note-api";

module("Unit | Lib | bookmark-note-api", function (hooks) {
  setupTest(hooks);

  test("loads a bookmark note", async function (assert) {
    pretender.get("/bookmark-notes/42.json", () =>
      response({ raw: "Private note" })
    );

    const result = await loadBookmarkNote(42);

    assert.deepEqual(result, { raw: "Private note" }, "returns the raw note");
  });

  test("saves a loaded bookmark note", async function (assert) {
    let raw;
    pretender.put("/bookmark-notes/42.json", (request) => {
      raw = new URLSearchParams(request.requestBody).get("raw");
      return response(204, {});
    });

    await saveBookmarkNote({ id: 42, bookmarkNoteRaw: "Private note" });

    assert.strictEqual(
      raw,
      "Private note",
      "sends the raw note to its owner-only endpoint"
    );
  });

  test("skips an editor that has not loaded", async function (assert) {
    let requests = 0;
    pretender.put("/bookmark-notes/42.json", () => {
      requests += 1;
      return response(204, {});
    });

    await saveBookmarkNote({ id: 42 });

    assert.strictEqual(requests, 0, "does not overwrite an unloaded note");
  });
});
