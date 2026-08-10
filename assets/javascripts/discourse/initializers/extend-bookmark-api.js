import { service } from "@ember/service";
import { withPluginApi } from "discourse/lib/plugin-api";
import PostBookmarkNoteButton from "../components/post-bookmark-note-button";
import { saveBookmarkNote } from "../lib/bookmark-note-api";

export default {
  name: "discourse-bookmark-notes-extend-bookmark-api",

  initialize() {
    withPluginApi((api) => {
      const siteSettings = api.container.lookup("service:site-settings");

      api.addTrackedPostProperties("bookmark_personal_note");

      if (siteSettings.discourse_bookmark_notes_post_button_enabled) {
        api.renderAfterWrapperOutlet(
          "post-content-cooked-html",
          PostBookmarkNoteButton
        );
      }

      api.modifyClass(
        "service:bookmark-api",
        (Superclass) =>
          class extends Superclass {
            @service appEvents;

            async create(bookmark) {
              const result = await super.create(bookmark);
              await saveBookmarkNote(bookmark);
              this.notifyNoteChanged(bookmark);
              return result;
            }

            async update(bookmark) {
              const result = await super.update(bookmark);
              await saveBookmarkNote(bookmark);
              this.notifyNoteChanged(bookmark);
              return result;
            }

            notifyNoteChanged(bookmark) {
              if (
                bookmark.bookmarkNoteRaw === undefined ||
                bookmark.bookmarkableType !== "Post"
              ) {
                return;
              }

              this.appEvents.trigger("bookmark-notes:changed", {
                postId: bookmark.bookmarkableId,
                note: bookmark.bookmarkNoteRaw.trim()
                  ? { bookmark_id: bookmark.id, title: bookmark.name }
                  : null,
              });
            }
          }
      );
    });
  },
};
