import { withPluginApi } from "discourse/lib/plugin-api";
import { saveBookmarkNote } from "../lib/bookmark-note-api";

export default {
  name: "discourse-bookmark-notes-extend-bookmark-api",

  initialize() {
    withPluginApi((api) => {
      api.modifyClass(
        "service:bookmark-api",
        (Superclass) =>
          class extends Superclass {
            async create(bookmark) {
              const result = await super.create(bookmark);
              await saveBookmarkNote(bookmark);
              return result;
            }

            async update(bookmark) {
              const result = await super.update(bookmark);
              await saveBookmarkNote(bookmark);
              return result;
            }
          }
      );
    });
  },
};
