| | | |
| - | - | - |
| :information_source: | **Summary** | A Discourse plugin that turns bookmarks into private personal notes attached to posts and other bookmarkable content |
| :hammer_and_wrench: | **Repository Link** | <https://github.com/merefield/discourse-bookmark-notes> |
| :open_book: | **Install Guide** | [How to install plugins in Discourse](https://meta.discourse.org/t/install-plugins-in-discourse/19157) |
| :heart: | **Sponsorship** | Please consider becoming an ongoing [sponsor of my open source work](https://github.com/sponsors/merefield) at a level that suits your or your organisation's resources and needs to ensure this plugin gets the maintenance it deserves and continues to work for your site in the future. |

Enjoying this plugin? Please :star: it on [GitHub](https://github.com/merefield/discourse-bookmark-notes)! :pray:

![A bookmark with a title and Markdown personal note](https://raw.githubusercontent.com/merefield/discourse-bookmark-notes/main/docs/bookmark-notes.png)

### Features

Discourse Bookmark Notes extends the existing bookmark experience rather than introducing a separate notes system:

* Uses the bookmark's existing name as the note title.
* Adds a private personal-note body using Discourse's Markdown editor, including its formatting toolbar and rendered preview.
* Shows a button below a post when the current user has saved a non-empty note, making the bookmark modal easy to reopen.
* Keeps notes private to the user who owns each bookmark. Different users can bookmark the same post and maintain completely independent notes.
* Preserves bookmark reminders, auto-delete preferences, bookmark controls, and the bookmarks activity list.
* Supports creating, updating, and removing a note without removing its bookmark.

### Settings

The plugin provides two settings, both enabled by default:

* `discourse_bookmark_notes_enabled` enables or disables the plugin.
* `discourse_bookmark_notes_post_button_enabled` controls the note button shown below posts with non-empty notes.

### Privacy and storage

Note bodies are stored in a plugin-owned `BookmarkNote` record with a one-to-one relationship to the core bookmark. Removing the bookmark also removes its personal note.

Notes are loaded and saved through owner-authorized endpoints. Topic pages expose bookmark-note data only to the signed-in bookmark owner; one user's note is never added to another user's post or bookmark payload.

### Pro extension

[Discourse Bookmark Notes Pro](https://github.com/merefield/discourse-bookmark-notes-pro-ext) is an optional extension available to GitHub Sponsors as a thank-you for supporting ongoing development. Individual sponsors on the $7/month tier receive access and private-repository installation instructions.

The Pro extension adds independently configurable features:

* A private, collapsible panel below a bookmarked post showing the full rendered note.
* Personal notes appended to entries on the current user's bookmarks activity page.
* Bookmark search extended to include the current user's bookmark titles and personal-note bodies when using `in:bookmarks`.
* A sortable **Notes** column on topic lists, indicating when the current user has a note on the topic or any of its posts.

**[Sponsor on GitHub to get Bookmark Notes Pro](https://github.com/sponsors/merefield)**
