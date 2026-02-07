// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: zoekenPage

    property string searchText: ""

    // ── Filtered results ─────────────────────────────────────────────────
    property var searchResults: {
        var results = []
        var query = searchText.toLowerCase().trim()
        if (query.length === 0) return results

        var subs = appStore.subjects
        if (!subs) return results

        for (var i = 0; i < subs.length; i++) {
            var subject = subs[i]
            var subjectName = (subject.naam || "").toLowerCase()

            // Match the subject itself
            if (subjectName.indexOf(query) !== -1) {
                results.push({
                    type: "subject",
                    id: subject.id,
                    naam: subject.naam,
                    icon: subject.icon,
                    detail: subject.topics ? subject.topics.length + " onderwerpen" : ""
                })
            }

            // Match topics
            var topics = subject.topics || []
            for (var j = 0; j < topics.length; j++) {
                var topic = topics[j]
                var topicTitle = (topic.titel || "").toLowerCase()
                if (topicTitle.indexOf(query) !== -1) {
                    results.push({
                        type: "topic",
                        id: topic.id,
                        subjectId: topic.subjectId,
                        naam: topic.titel,
                        icon: subject.icon,
                        detail: subject.naam
                    })
                }
            }
        }

        return results
    }

    // ── Fade-in ──────────────────────────────────────────────────────────
    opacity: 0
    Component.onCompleted: fadeIn.start()

    OpacityAnimator {
        id: fadeIn
        target: zoekenPage
        from: 0; to: 1
        duration: Theme.animSlow
        easing.type: Easing.OutCubic
    }

    Column {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingXl
        anchors.rightMargin: Theme.spacingXl
        spacing: Theme.spacingXl

        // ── Header ───────────────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: Theme.spacingSm
            topPadding: Theme.spacingXl

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Zoeken"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize2xl
                font.weight: Theme.fontWeightBold
                color: Theme.textPrimary
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Zoek naar vakken en onderwerpen"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMd
                color: Theme.textSecondary
            }
        }

        // ── Search Input ─────────────────────────────────────────────────
        GlassInput {
            id: searchInput
            width: Math.min(parent.width, 560)
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: "Typ om te zoeken..."
            focus: true

            onTextChanged: zoekenPage.searchText = text

            Component.onCompleted: forceActiveFocus()
        }

        // ── Result Count ─────────────────────────────────────────────────
        Text {
            visible: searchText.trim().length > 0
            text: searchResults.length + " " + (searchResults.length === 1 ? "resultaat" : "resultaten") + " gevonden"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSm
            color: Theme.textSecondary
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // ── Results List ─────────────────────────────────────────────────
        Flickable {
            width: parent.width
            height: parent.height - y - Theme.spacingXl
            contentHeight: resultsColumn.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 4
                    radius: 2
                    color: Theme.textTertiary
                    opacity: 0.5
                }
            }

            Column {
                id: resultsColumn
                width: parent.width
                spacing: Theme.spacingMd

                Repeater {
                    model: zoekenPage.searchResults

                    GlassPanel {
                        id: resultItem
                        width: resultsColumn.width
                        height: 68
                        radius: Theme.radiusPanel

                        required property var modelData
                        required property int index

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingLg
                            anchors.rightMargin: Theme.spacingLg
                            spacing: Theme.spacingMd

                            // Icon
                            Text {
                                text: resultItem.modelData.icon || ""
                                font.pixelSize: 28
                                Layout.alignment: Qt.AlignVCenter
                            }

                            // Info
                            Column {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                Text {
                                    text: resultItem.modelData.naam || ""
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeMd
                                    font.weight: Theme.fontWeightMedium
                                    color: Theme.textPrimary
                                    width: parent.width
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: resultItem.modelData.detail || ""
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSm
                                    color: Theme.textSecondary
                                }
                            }

                            // Type badge
                            Rectangle {
                                width: typeBadgeText.width + Theme.spacingMd * 2
                                height: 24
                                radius: Theme.radiusSmall
                                color: resultItem.modelData.type === "subject" ? Theme.accentDim : Qt.rgba(16/255, 185/255, 129/255, 0.15)
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    id: typeBadgeText
                                    anchors.centerIn: parent
                                    text: resultItem.modelData.type === "subject" ? "Vak" : "Onderwerp"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeXs
                                    font.weight: Theme.fontWeightMedium
                                    color: resultItem.modelData.type === "subject" ? Theme.accent : Theme.correct
                                }
                            }

                            // Arrow
                            Text {
                                text: "\u2192"
                                font.pixelSize: Theme.fontSizeLg
                                color: Theme.textTertiary
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                if (resultItem.modelData.type === "subject") {
                                    appStore.navigateToSubject(resultItem.modelData.id)
                                } else {
                                    appStore.navigateToTopic(resultItem.modelData.id)
                                }
                            }
                            onEntered: resultItem.opacity = 0.85
                            onExited: resultItem.opacity = 1.0
                        }
                    }
                }

                // Empty state when searching
                Text {
                    visible: searchText.trim().length > 0 && zoekenPage.searchResults.length === 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Geen resultaten gevonden voor \"" + searchText + "\""
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: Theme.textTertiary
                    topPadding: Theme.spacing2xl
                }

                // Initial state
                Text {
                    visible: searchText.trim().length === 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Begin met typen om te zoeken"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: Theme.textTertiary
                    topPadding: Theme.spacing2xl
                }
            }
        }
    }
}
