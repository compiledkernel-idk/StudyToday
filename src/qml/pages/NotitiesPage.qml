// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: notitiesPage

    // ── Data ─────────────────────────────────────────────────────────────
    property var notes: appStore.notes || []
    property int selectedIndex: -1
    property var selectedNote: selectedIndex >= 0 && selectedIndex < notes.length ? notes[selectedIndex] : null

    // ── Debounce save timer ──────────────────────────────────────────────
    Timer {
        id: saveTimer
        interval: 800
        repeat: false
        onTriggered: {
            if (notitiesPage.selectedNote && notitiesPage.selectedNote.topicId !== undefined) {
                appStore.addNote(
                    notitiesPage.selectedNote.topicId,
                    titleInput.text,
                    contentArea.text
                )
            }
        }
    }

    // ── Fade-in ──────────────────────────────────────────────────────────
    opacity: 0
    Component.onCompleted: fadeIn.start()

    OpacityAnimator {
        id: fadeIn
        target: notitiesPage
        from: 0; to: 1
        duration: Theme.animSlow
        easing.type: Easing.OutCubic
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingXl
        spacing: Theme.spacingLg

        // ── Left Panel: Note List ────────────────────────────────────────
        GlassPanel {
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            radius: Theme.radiusPanel

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacingMd
                spacing: Theme.spacingMd

                // Header
                RowLayout {
                    width: parent.width
                    spacing: Theme.spacingSm

                    Text {
                        text: "Notities"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeLg
                        font.weight: Theme.fontWeightSemiBold
                        color: Theme.textPrimary
                        Layout.fillWidth: true
                    }

                    // New note button
                    GlassButton {
                        text: "+"
                        onClicked: {
                            appStore.addNote(0, "Nieuwe notitie", "")
                            // Select the newly created note
                            Qt.callLater(function() {
                                if (notitiesPage.notes.length > 0) {
                                    notitiesPage.selectedIndex = notitiesPage.notes.length - 1
                                }
                            })
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.glassBorder
                }

                // Notes list
                Flickable {
                    width: parent.width
                    height: parent.height - 60
                    contentHeight: notesList.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: 3
                            radius: 2
                            color: Theme.textTertiary
                            opacity: 0.5
                        }
                    }

                    Column {
                        id: notesList
                        width: parent.width
                        spacing: Theme.spacingXs

                        Repeater {
                            model: notitiesPage.notes

                            Rectangle {
                                id: noteItem
                                width: notesList.width
                                height: 56
                                radius: Theme.radiusSmall
                                color: notitiesPage.selectedIndex === index
                                    ? Theme.accentDim
                                    : mouseArea.containsMouse
                                        ? Theme.glassHover
                                        : "transparent"

                                required property var modelData
                                required property int index

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: Theme.spacingMd
                                    anchors.rightMargin: Theme.spacingMd
                                    spacing: 2

                                    Text {
                                        text: noteItem.modelData.title || "Zonder titel"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeSm
                                        font.weight: Theme.fontWeightMedium
                                        color: notitiesPage.selectedIndex === noteItem.index
                                            ? Theme.accent
                                            : Theme.textPrimary
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: {
                                            var c = noteItem.modelData.content || ""
                                            return c.length > 40 ? c.substring(0, 40) + "..." : (c || "Lege notitie")
                                        }
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeXs
                                        color: Theme.textTertiary
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: notitiesPage.selectedIndex = noteItem.index
                                }

                                Behavior on color {
                                    ColorAnimation { duration: Theme.animFast }
                                }
                            }
                        }

                        // Empty state
                        Text {
                            visible: notitiesPage.notes.length === 0
                            text: "Nog geen notities.\nKlik op + om te beginnen."
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            color: Theme.textTertiary
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.width
                            topPadding: Theme.spacingXl
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

        // ── Right Panel: Editor ──────────────────────────────────────────
        GlassPanel {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Theme.radiusPanel

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacingLg
                spacing: Theme.spacingMd

                // Editor - No note selected state
                Column {
                    visible: notitiesPage.selectedNote === null
                    anchors.centerIn: parent
                    spacing: Theme.spacingMd

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Selecteer een notitie"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeXl
                        font.weight: Theme.fontWeightSemiBold
                        color: Theme.textTertiary
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Kies een notitie uit de lijst of maak een nieuwe aan"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMd
                        color: Theme.textTertiary
                    }
                }

                // Title input
                TextField {
                    id: titleInput
                    visible: notitiesPage.selectedNote !== null
                    width: parent.width
                    text: notitiesPage.selectedNote ? (notitiesPage.selectedNote.title || "") : ""
                    placeholderText: "Titel..."
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeXl
                    font.weight: Theme.fontWeightBold
                    color: Theme.textPrimary
                    placeholderTextColor: Theme.textTertiary
                    background: Rectangle {
                        color: "transparent"
                        border.width: 0
                    }
                    padding: 0
                    bottomPadding: Theme.spacingSm

                    onTextChanged: {
                        if (notitiesPage.selectedNote) {
                            saveTimer.restart()
                        }
                    }
                }

                Rectangle {
                    visible: notitiesPage.selectedNote !== null
                    width: parent.width
                    height: 1
                    color: Theme.glassBorder
                }

                // Content area
                ScrollView {
                    visible: notitiesPage.selectedNote !== null
                    width: parent.width
                    height: parent.height - titleInput.height - Theme.spacingMd * 3 - 1

                    TextArea {
                        id: contentArea
                        text: notitiesPage.selectedNote ? (notitiesPage.selectedNote.content || "") : ""
                        placeholderText: "Begin met schrijven..."
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMd
                        color: Theme.textPrimary
                        placeholderTextColor: Theme.textTertiary
                        wrapMode: TextEdit.WordWrap
                        background: Rectangle {
                            color: "transparent"
                        }
                        padding: 0

                        onTextChanged: {
                            if (notitiesPage.selectedNote) {
                                saveTimer.restart()
                            }
                        }
                    }
                }
            }
        }
    }
}
