import { ajax } from "discourse/lib/ajax";

export function loadBookmarkNote(bookmarkId) {
  return ajax(`/bookmark-notes/${bookmarkId}.json`);
}

export function saveBookmarkNote(bookmark) {
  if (bookmark.bookmarkNoteRaw === undefined) {
    return;
  }

  return ajax(`/bookmark-notes/${bookmark.id}.json`, {
    type: "PUT",
    data: { raw: bookmark.bookmarkNoteRaw },
  });
}
