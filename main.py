# SPDX-FileCopyrightText: 2026 compiledkernel-idk
#
# SPDX-License-Identifier: GPL-3.0-or-later

import sys
import os
from pathlib import Path

from PySide6.QtGui import QGuiApplication, QFontDatabase, QFont
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterSingletonType
from PySide6.QtCore import QUrl

from src.models.app_store import AppStore
from src.models.sample_content import get_sample_subjects
from src.models.updater import AppUpdater


def main():
    app = QGuiApplication(sys.argv)
    app.setApplicationName("StudyToday")
    app.setOrganizationName("StudyToday")

    # Set default font
    font = QFont("Inter", 10)
    font.setStyleStrategy(QFont.StyleStrategy.PreferAntialias)
    app.setFont(font)

    # Create store and load sample content
    store = AppStore()
    store.setSyncStatus("syncing")

    subjects = get_sample_subjects()
    store.setSubjects(subjects)
    store.setSyncStatus("done")
    store.setLastSha("sample-local")

    # QML engine
    engine = QQmlApplicationEngine()

    # Auto-updater
    updater = AppUpdater()

    # Expose to QML
    engine.rootContext().setContextProperty("appStore", store)
    engine.rootContext().setContextProperty("appUpdater", updater)

    # Add QML import path
    qml_dir = Path(__file__).parent / "src" / "qml"
    engine.addImportPath(str(qml_dir))

    # Load main QML
    qml_file = qml_dir / "main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        print("Failed to load QML. Check for errors above.", file=sys.stderr)
        sys.exit(1)

    # Check for updates in background
    updater.checkForUpdates()

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
