# Discourse Bookmark Notes

Discourse Bookmark Notes turns bookmarks into private, personal notes attached to posts and other bookmarkable content.

![A bookmark with a title and Markdown personal note](docs/bookmark-notes.png)

## Functionality

- Uses the bookmark's existing name as the note title.
- Adds a personal note body using Discourse's Markdown editor, including a live rendered preview.
- Keeps each note private to the user who owns the bookmark. Multiple users can bookmark the same post and keep completely independent notes.
- Preserves Discourse's existing bookmark reminders, auto-delete preferences, bookmark controls, and bookmarks list.
- Supports creating, updating, and removing a note without removing its bookmark.

## Privacy and storage

Note bodies are stored in a plugin-owned `BookmarkNote` record with a one-to-one relationship to the core `Bookmark`. They are loaded and saved through owner-authorized endpoints and are not exposed through topic, bookmark-list, reminder, or notification serializers.
