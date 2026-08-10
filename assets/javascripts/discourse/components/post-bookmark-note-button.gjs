import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import { service } from "@ember/service";
import BookmarkModal from "discourse/components/modal/bookmark";
import { popupAjaxError } from "discourse/lib/ajax-error";
import PostBookmarkManager from "discourse/lib/post-bookmark-manager";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";

export default class PostBookmarkNoteButton extends Component {
  @service appEvents;
  @service modal;
  @service siteSettings;

  @tracked note;

  constructor() {
    super(...arguments);
    this.note = this.args.post.bookmark_personal_note;
    this.appEvents.on("bookmark-notes:changed", this, this.noteChanged);
    this.appEvents.on("bookmarks:changed", this, this.bookmarkChanged);
  }

  willDestroy() {
    this.appEvents.off("bookmark-notes:changed", this, this.noteChanged);
    this.appEvents.off("bookmarks:changed", this, this.bookmarkChanged);
    super.willDestroy(...arguments);
  }

  get shouldShow() {
    const proPanelEnabled =
      this.siteSettings.discourse_bookmark_notes_pro_ext_enabled &&
      this.siteSettings.discourse_bookmark_notes_pro_post_panel_enabled;

    return (
      this.note &&
      this.siteSettings.discourse_bookmark_notes_post_button_enabled &&
      !proPanelEnabled
    );
  }

  get label() {
    if (this.note.title) {
      return i18n("discourse_bookmark_notes.titled_post_button", {
        title: this.note.title,
      });
    }

    return i18n("discourse_bookmark_notes.post_button");
  }

  @action
  noteChanged({ postId, note }) {
    if (postId === this.args.post.id) {
      this.note = note;
    }
  }

  @action
  bookmarkChanged(bookmark, context) {
    if (
      !bookmark &&
      context?.target === "post" &&
      context.targetId === this.args.post.id
    ) {
      this.note = null;
    }
  }

  @action
  async openBookmarkModal() {
    const bookmarkManager = new PostBookmarkManager(
      getOwner(this),
      this.args.post
    );

    try {
      const closeData = await this.modal.show(BookmarkModal, {
        model: {
          bookmark: bookmarkManager.trackedBookmark,
          afterSave: (savedData) => bookmarkManager.afterSave(savedData),
          afterDelete: (response, bookmarkId) =>
            bookmarkManager.afterDelete(response, bookmarkId),
        },
      });
      bookmarkManager.afterModalClose(closeData);
    } catch (error) {
      popupAjaxError(error);
    }
  }

  <template>
    {{#if this.shouldShow}}
      <div class="post-bookmark-note-button">
        <DButton
          @icon="file-lines"
          @translatedLabel={{this.label}}
          @action={{this.openBookmarkModal}}
          @title="discourse_bookmark_notes.edit_post_note"
          class="btn-flat post-bookmark-note-button__trigger"
        />
      </div>
    {{/if}}
  </template>
}
