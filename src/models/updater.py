"""
updater.py - Auto-update checker for StudyToday.

Checks GitHub Releases for new versions, downloads the appropriate binary,
and replaces the running executable.
"""

from __future__ import annotations

import json
import os
import platform
import stat
import sys
import tempfile
import threading
import urllib.request
from typing import Optional

from PySide6.QtCore import QObject, Property, Signal, Slot

APP_VERSION = "1.0.0"

GITHUB_REPO = "compiledkernel-idk/StudyToday"
GITHUB_API_URL = f"https://api.github.com/repos/{GITHUB_REPO}/releases/latest"


def _parse_version(tag: str) -> tuple[int, ...]:
    """Parse 'v1.2.3' or '1.2.3' into (1, 2, 3)."""
    clean = tag.lstrip("vV")
    parts = []
    for p in clean.split("."):
        try:
            parts.append(int(p))
        except ValueError:
            break
    return tuple(parts)


class AppUpdater(QObject):

    # Signals
    updateAvailableChanged = Signal()
    latestVersionChanged = Signal()
    downloadProgressChanged = Signal()
    updateStatusChanged = Signal()

    def __init__(self, parent: Optional[QObject] = None) -> None:
        super().__init__(parent)
        self._update_available: bool = False
        self._latest_version: str = APP_VERSION
        self._download_progress: float = 0.0
        self._update_status: str = "idle"
        self._download_url: str = ""
        self._downloaded_path: str = ""

    # ── Properties ────────────────────────────────────────────────────

    @Property(bool, notify=updateAvailableChanged)
    def updateAvailable(self) -> bool:
        return self._update_available

    @Property(str, notify=latestVersionChanged)
    def latestVersion(self) -> str:
        return self._latest_version

    @Property(float, notify=downloadProgressChanged)
    def downloadProgress(self) -> float:
        return self._download_progress

    @Property(str, notify=updateStatusChanged)
    def updateStatus(self) -> str:
        return self._update_status

    @Property(str, constant=True)
    def currentVersion(self) -> str:
        return APP_VERSION

    # ── Internal setters ──────────────────────────────────────────────

    def _set_status(self, status: str) -> None:
        if self._update_status != status:
            self._update_status = status
            self.updateStatusChanged.emit()

    def _set_progress(self, progress: float) -> None:
        self._download_progress = progress
        self.downloadProgressChanged.emit()

    # ── Slots ─────────────────────────────────────────────────────────

    @Slot()
    def checkForUpdates(self) -> None:
        """Check GitHub releases in a background thread."""
        self._set_status("checking")
        thread = threading.Thread(target=self._check_worker, daemon=True)
        thread.start()

    @Slot()
    def downloadUpdate(self) -> None:
        """Download the new binary in a background thread."""
        if not self._download_url:
            return
        self._set_status("downloading")
        self._set_progress(0.0)
        thread = threading.Thread(target=self._download_worker, daemon=True)
        thread.start()

    @Slot()
    def installAndRestart(self) -> None:
        """Replace current executable and restart."""
        if not self._downloaded_path or not os.path.exists(self._downloaded_path):
            self._set_status("error")
            return

        current_exe = sys.executable
        is_frozen = getattr(sys, "frozen", False)

        if not is_frozen:
            # Running from source — nothing to replace
            self._set_status("error")
            return

        if platform.system() == "Windows":
            self._install_windows(current_exe)
        else:
            self._install_linux(current_exe)

    # ── Background workers ────────────────────────────────────────────

    def _check_worker(self) -> None:
        try:
            req = urllib.request.Request(
                GITHUB_API_URL,
                headers={"Accept": "application/vnd.github.v3+json",
                         "User-Agent": "StudyToday-Updater"},
            )
            with urllib.request.urlopen(req, timeout=10) as resp:
                data = json.loads(resp.read().decode())

            tag = data.get("tag_name", "")
            remote_ver = _parse_version(tag)
            local_ver = _parse_version(APP_VERSION)

            if remote_ver > local_ver:
                # Find the right asset
                asset_name = self._get_asset_name()
                download_url = ""
                for asset in data.get("assets", []):
                    if asset["name"] == asset_name:
                        download_url = asset["browser_download_url"]
                        break

                self._latest_version = tag.lstrip("vV")
                self.latestVersionChanged.emit()
                self._download_url = download_url
                self._update_available = True
                self.updateAvailableChanged.emit()
                self._set_status("available")
            else:
                self._set_status("idle")

        except Exception:
            self._set_status("idle")  # Fail silently

    def _download_worker(self) -> None:
        try:
            req = urllib.request.Request(
                self._download_url,
                headers={"User-Agent": "StudyToday-Updater"},
            )
            with urllib.request.urlopen(req, timeout=120) as resp:
                total = int(resp.headers.get("Content-Length", 0))
                suffix = ".exe" if platform.system() == "Windows" else ""
                fd, tmp_path = tempfile.mkstemp(prefix="studytoday-update-", suffix=suffix)

                downloaded = 0
                with os.fdopen(fd, "wb") as f:
                    while True:
                        chunk = resp.read(65536)
                        if not chunk:
                            break
                        f.write(chunk)
                        downloaded += len(chunk)
                        if total > 0:
                            self._set_progress(downloaded / total)

            self._downloaded_path = tmp_path
            self._set_progress(1.0)
            self._set_status("ready")

        except Exception:
            self._set_status("error")

    # ── Platform-specific install ─────────────────────────────────────

    def _install_linux(self, current_exe: str) -> None:
        try:
            os.chmod(self._downloaded_path, os.stat(current_exe).st_mode | stat.S_IEXEC)
            os.replace(self._downloaded_path, current_exe)
            os.execv(current_exe, [current_exe] + sys.argv[1:])
        except Exception:
            self._set_status("error")

    def _install_windows(self, current_exe: str) -> None:
        try:
            bat = os.path.join(tempfile.gettempdir(), "studytoday_update.bat")
            with open(bat, "w") as f:
                f.write(f'@echo off\n')
                f.write(f'timeout /t 2 /nobreak >nul\n')
                f.write(f'move /Y "{self._downloaded_path}" "{current_exe}"\n')
                f.write(f'start "" "{current_exe}"\n')
                f.write(f'del "%~f0"\n')
            os.startfile(bat)
            sys.exit(0)
        except Exception:
            self._set_status("error")

    @staticmethod
    def _get_asset_name() -> str:
        if platform.system() == "Windows":
            return "StudyToday-Windows.exe"
        return "StudyToday-Linux"
