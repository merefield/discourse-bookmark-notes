import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { isDestroyed, isDestroying } from "@ember/destroyable";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DEditor from "discourse/ui-kit/d-editor";
import dLoadingSpinner from "discourse/ui-kit/helpers/d-loading-spinner";
import { i18n } from "discourse-i18n";
import { loadBookmarkNote } from "../../lib/bookmark-note-api";

export default class BookmarkNoteEditor extends Component {
  @service a11y;

  @tracked raw = "";
  @tracked loading = false;
  @tracked loadFailed = false;

  constructor() {
    super(...arguments);

    if (this.bookmark.id) {
      this.load();
    } else {
      this.bookmark.bookmarkNoteRaw = "";
    }
  }

  get bookmark() {
    return this.args.outletArgs.bookmark;
  }

  async load() {
    this.loading = true;

    try {
      const response = await loadBookmarkNote(this.bookmark.id);
      if (isDestroying(this) || isDestroyed(this)) {
        return;
      }

      this.raw = response.raw;
      this.bookmark.bookmarkNoteRaw = response.raw;
    } catch {
      if (isDestroying(this) || isDestroyed(this)) {
        return;
      }

      this.loadFailed = true;
      this.a11y.announce(i18n("discourse_bookmark_notes.load_error"), "assertive");
    } finally {
      if (!isDestroying(this) && !isDestroyed(this)) {
        this.loading = false;
      }
    }
  }

  @action
  updateRaw(event) {
    this.raw = event.target.value;
    this.bookmark.bookmarkNoteRaw = this.raw;
  }

  @action
  stopEnterPropagation(event) {
    if (event.key === "Enter") {
      event.stopPropagation();
    }
  }

  @action
  preventSubmit(event) {
    event.preventDefault();
  }

  <template>
    {{! eslint-disable-next-line ember/template-no-invalid-interactive }}
    <form
      class="bookmark-note-editor"
      aria-labelledby="bookmark-note-label"
      {{on "keydown" this.stopEnterPropagation}}
      {{on "submit" this.preventSubmit}}
    >
      <label
        id="bookmark-note-label"
        class="control-label"
        for="bookmark-note-raw"
      >
        {{i18n "discourse_bookmark_notes.label"}}
      </label>

      {{#if this.loading}}
        <div class="bookmark-note-editor__loading">
          {{dLoadingSpinner size="small"}}
        </div>
      {{else if this.loadFailed}}
        <div class="alert alert-error">
          {{i18n "discourse_bookmark_notes.load_error"}}
        </div>
      {{else}}
        <DEditor
          @value={{this.raw}}
          @change={{this.updateRaw}}
          @placeholder={{i18n "discourse_bookmark_notes.placeholder"}}
          @textAreaId="bookmark-note-raw"
          class="bookmark-note-editor__composer"
        />
      {{/if}}
    </form>
  </template>
}
