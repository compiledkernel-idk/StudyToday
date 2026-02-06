"""
app_store.py - Main state management QObject for the StudyToday Qt/QML app.

Exposes all application state as Q_PROPERTYs with change signals so that QML
can bind to them reactively.  All mutating methods are decorated with @Slot so
they can be called directly from QML.
"""

from __future__ import annotations

import uuid
from datetime import datetime
from typing import Any, Optional

from PySide6.QtCore import QObject, Property, Signal, Slot


class AppStore(QObject):
    """Central application state, designed to be registered as a QML context
    property (e.g. ``engine.rootContext().setContextProperty("store", store)``).
    """

    # ------------------------------------------------------------------ #
    #  Signals (NOTIFY for each Q_PROPERTY)
    # ------------------------------------------------------------------ #
    subjectsChanged = Signal()
    bookmarksChanged = Signal()
    notesChanged = Signal()
    sessionsChanged = Signal()
    syncStatusChanged = Signal()
    lastSyncShaChanged = Signal()
    currentPageChanged = Signal()
    currentSubjectIdChanged = Signal()
    currentTopicIdChanged = Signal()

    def __init__(self, parent: Optional[QObject] = None) -> None:
        super().__init__(parent)

        # Internal state
        self._subjects: list[dict[str, Any]] = []
        self._bookmarks: list[dict[str, Any]] = []
        self._notes: list[dict[str, Any]] = []
        self._sessions: list[dict[str, Any]] = []
        self._sync_status: str = "idle"
        self._last_sync_sha: str = ""
        self._current_page: str = "home"
        self._current_subject_id: str = ""
        self._current_topic_id: str = ""

    # ------------------------------------------------------------------ #
    #  Q_PROPERTY definitions
    # ------------------------------------------------------------------ #

    @Property(list, notify=subjectsChanged)
    def subjects(self) -> list:
        return self._subjects

    @Property(list, notify=bookmarksChanged)
    def bookmarks(self) -> list:
        return self._bookmarks

    @Property(list, notify=notesChanged)
    def notes(self) -> list:
        return self._notes

    @Property(list, notify=sessionsChanged)
    def sessions(self) -> list:
        return self._sessions

    @Property(str, notify=syncStatusChanged)
    def syncStatus(self) -> str:
        return self._sync_status

    @Property(str, notify=lastSyncShaChanged)
    def lastSyncSha(self) -> str:
        return self._last_sync_sha

    @Property(str, notify=currentPageChanged)
    def currentPage(self) -> str:
        return self._current_page

    @Property(str, notify=currentSubjectIdChanged)
    def currentSubjectId(self) -> str:
        return self._current_subject_id

    @Property(str, notify=currentTopicIdChanged)
    def currentTopicId(self) -> str:
        return self._current_topic_id

    # ------------------------------------------------------------------ #
    #  Slots — callable from QML
    # ------------------------------------------------------------------ #

    # --- Subjects ---

    @Slot(list)
    def setSubjects(self, subjects: list) -> None:
        """Replace the entire subjects list."""
        self._subjects = list(subjects)
        self.subjectsChanged.emit()

    # --- Sync ---

    @Slot(str)
    def setSyncStatus(self, status: str) -> None:
        """Update the synchronisation status string."""
        if self._sync_status != status:
            self._sync_status = status
            self.syncStatusChanged.emit()

    @Slot(str)
    def setLastSha(self, sha: str) -> None:
        """Store the SHA of the last successful sync."""
        if self._last_sync_sha != sha:
            self._last_sync_sha = sha
            self.lastSyncShaChanged.emit()

    # --- Bookmarks ---

    @Slot(str)
    def addBookmark(self, topic_id: str) -> None:
        """Add a bookmark for *topic_id* (no-op if already bookmarked)."""
        for bm in self._bookmarks:
            if bm.get("topicId") == topic_id:
                return
        self._bookmarks.append({
            "topicId": topic_id,
            "timestamp": datetime.now().isoformat(),
        })
        self.bookmarksChanged.emit()

    @Slot(str)
    def removeBookmark(self, topic_id: str) -> None:
        """Remove the bookmark for *topic_id*."""
        original_len = len(self._bookmarks)
        self._bookmarks = [
            bm for bm in self._bookmarks if bm.get("topicId") != topic_id
        ]
        if len(self._bookmarks) != original_len:
            self.bookmarksChanged.emit()

    # --- Notes ---

    @Slot(str, str, str)
    def addNote(self, topic_id: str, title: str, content: str) -> None:
        """Create a new note attached to *topic_id*."""
        note: dict[str, Any] = {
            "id": str(uuid.uuid4()),
            "topicId": topic_id,
            "title": title,
            "content": content,
            "updatedAt": datetime.now().isoformat(),
        }
        self._notes.append(note)
        self.notesChanged.emit()

    @Slot(str, str, str)
    def updateNote(self, note_id: str, title: str, content: str) -> None:
        """Update an existing note identified by *note_id*."""
        for note in self._notes:
            if note.get("id") == note_id:
                note["title"] = title
                note["content"] = content
                note["updatedAt"] = datetime.now().isoformat()
                self.notesChanged.emit()
                return

    @Slot(str)
    def deleteNote(self, note_id: str) -> None:
        """Delete the note with *note_id*."""
        original_len = len(self._notes)
        self._notes = [n for n in self._notes if n.get("id") != note_id]
        if len(self._notes) != original_len:
            self.notesChanged.emit()

    # --- Study Sessions ---

    @Slot(str, int)
    def addSession(self, subject_id: str, duration: int) -> None:
        """Record a completed study session.

        Parameters
        ----------
        subject_id:
            The subject the session belongs to.
        duration:
            Duration in seconds.
        """
        session: dict[str, Any] = {
            "id": str(uuid.uuid4()),
            "subjectId": subject_id,
            "startedAt": datetime.now().isoformat(),
            "duration": duration,
        }
        self._sessions.append(session)
        self.sessionsChanged.emit()

    # --- Navigation ---

    @Slot(str)
    def navigate(self, page: str) -> None:
        """Navigate to a top-level page (e.g. ``"home"``, ``"bookmarks"``)."""
        if self._current_page != page:
            self._current_page = page
            self.currentPageChanged.emit()

    @Slot(str)
    def navigateToSubject(self, subject_id: str) -> None:
        """Navigate to the subject detail page for *subject_id*."""
        changed = False
        if self._current_subject_id != subject_id:
            self._current_subject_id = subject_id
            changed = True
            self.currentSubjectIdChanged.emit()
        if self._current_page != "subject":
            self._current_page = "subject"
            self.currentPageChanged.emit()
        elif changed:
            # Same page name but different subject — still emit so QML refreshes
            self.currentPageChanged.emit()

    @Slot(str)
    def navigateToTopic(self, topic_id: str) -> None:
        """Navigate to the topic detail page for *topic_id*."""
        changed = False
        if self._current_topic_id != topic_id:
            self._current_topic_id = topic_id
            changed = True
            self.currentTopicIdChanged.emit()
        if self._current_page != "topic":
            self._current_page = "topic"
            self.currentPageChanged.emit()
        elif changed:
            self.currentPageChanged.emit()

    # ------------------------------------------------------------------ #
    #  Helper methods (also exposed to QML)
    # ------------------------------------------------------------------ #

    @Slot(result=str)
    def getGreeting(self) -> str:
        """Return a Dutch time-based greeting string."""
        hour = datetime.now().hour
        if 6 <= hour < 12:
            return "Goedemorgen"
        elif 12 <= hour < 18:
            return "Goedemiddag"
        elif 18 <= hour < 22:
            return "Goedenavond"
        else:
            return "Goedenacht"

    @Slot(str, result="QVariant")
    def getSubjectById(self, subject_id: str) -> Any:
        """Return the subject dict for *subject_id*, or ``None``."""
        for subject in self._subjects:
            if subject.get("id") == subject_id:
                return subject
        return None

    @Slot(str, result="QVariant")
    def getTopicById(self, topic_id: str) -> Any:
        """Return the topic dict for *topic_id*, or ``None``.

        Searches across all subjects.
        """
        for subject in self._subjects:
            for topic in subject.get("topics", []):
                if topic.get("id") == topic_id:
                    return topic
        return None

    @Slot(str, result=bool)
    def isBookmarked(self, topic_id: str) -> bool:
        """Check whether *topic_id* is currently bookmarked."""
        return any(bm.get("topicId") == topic_id for bm in self._bookmarks)

    @Slot(str, result=list)
    def getNotesForTopic(self, topic_id: str) -> list:
        """Return all notes for a given *topic_id*."""
        return [n for n in self._notes if n.get("topicId") == topic_id]

    @Slot(str, result=list)
    def getSessionsForSubject(self, subject_id: str) -> list:
        """Return all study sessions for a given *subject_id*."""
        return [s for s in self._sessions if s.get("subjectId") == subject_id]

    @Slot(result=int)
    def getTotalStudyTime(self) -> int:
        """Return total study time across all sessions, in seconds."""
        return sum(s.get("duration", 0) for s in self._sessions)
