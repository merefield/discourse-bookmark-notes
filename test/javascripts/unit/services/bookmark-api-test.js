import { setupTest } from "ember-qunit";
import { module, test } from "qunit";
import pretender, { response } from "discourse/tests/helpers/create-pretender";

module("Unit | Service | bookmark-api", function (hooks) {
  setupTest(hooks);

  test("saves a note after creating its bookmark", async function (assert) {
    const requests = [];
    pretender.post("/bookmarks.json", () => {
      requests.push("bookmark");
      return response({ id: 42 });
    });
    pretender.put("/bookmark-notes/42.json", () => {
      requests.push("note");
      return response(204, {});
    });

    const bookmark = {
      id: null,
      bookmarkNoteRaw: "Private note",
      saveData: {
        bookmarkable_id: 1,
        bookmarkable_type: "Post",
      },
    };

    await this.owner.lookup("service:bookmark-api").create(bookmark);

    assert.strictEqual(bookmark.id, 42, "assigns the new bookmark id");
    assert.deepEqual(
      requests,
      ["bookmark", "note"],
      "saves the note after the bookmark exists"
    );
  });

  test("rejects when saving the note fails", async function (assert) {
    pretender.put("/bookmarks/42.json", () => response({ success: "OK" }));
    pretender.put("/bookmark-notes/42.json", () =>
      response(422, { errors: ["Raw is too long"] })
    );

    const bookmark = {
      id: 42,
      bookmarkNoteRaw: "Private note",
      saveData: { id: 42 },
    };

    await assert.rejects(
      this.owner.lookup("service:bookmark-api").update(bookmark),
      "keeps the core modal open for a note error"
    );
  });
});
