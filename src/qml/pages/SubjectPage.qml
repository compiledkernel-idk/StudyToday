// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: subjectPage

    // ── Data ─────────────────────────────────────────────────────────────
    property var currentSubject: {
        var sid = appStore.currentSubjectId
        var subs = appStore.subjects
        if (subs) {
            for (var i = 0; i < subs.length; i++) {
                if (subs[i].id === sid) return subs[i]
            }
        }
        return null
    }

    property string subjectName: currentSubject ? (currentSubject.naam || "") : ""
    property string subjectIcon: currentSubject ? (currentSubject.icon || "") : ""
    property var topics: currentSubject ? (currentSubject.topics || []) : []

    // ── Fade-in ──────────────────────────────────────────────────────────
    opacity: 0
    Component.onCompleted: fadeIn.start()

    OpacityAnimator {
        id: fadeIn
        target: subjectPage
        from: 0; to: 1
        duration: Theme.animSlow
        easing.type: Easing.OutCubic
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height + Theme.spacing3xl
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
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.spacingXl
            anchors.rightMargin: Theme.spacingXl
            spacing: Theme.spacingXl

            // ── Back Button ──────────────────────────────────────────────
            Item {
                width: parent.width
                height: backBtn.height + Theme.spacingLg

                GlassButton {
                    id: backBtn
                    y: Theme.spacingLg
                    text: "\u2190 Terug"
                    onClicked: appStore.navigate("vakken")
                }
            }

            // ── Subject Header ───────────────────────────────────────────
            Row {
                spacing: Theme.spacingLg
                topPadding: Theme.spacingSm

                Text {
                    text: subjectPage.subjectIcon
                    font.pixelSize: 48
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingXs

                    Text {
                        text: subjectPage.subjectName
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize2xl
                        font.weight: Theme.fontWeightBold
                        color: Theme.textPrimary
                    }

                    Text {
                        property int count: subjectPage.topics.length
                        text: count + (count === 1 ? " onderwerp" : " onderwerpen")
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMd
                        color: Theme.textSecondary
                    }
                }
            }

            // ── Separator ────────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.glassBorder
            }

            // ── Topic List ───────────────────────────────────────────────
            Column {
                width: parent.width
                spacing: Theme.spacingMd

                Repeater {
                    model: subjectPage.topics

                    GlassPanel {
                        id: topicItem
                        width: subjectPage.width - 2 * Theme.spacingXl
                        height: 64
                        radius: Theme.radiusPanel

                        required property var modelData
                        required property int index

                        // Staggered fade
                        opacity: 0
                        Component.onCompleted: topicFadeIn.start()
                        OpacityAnimator {
                            id: topicFadeIn
                            target: topicItem
                            from: 0; to: 1
                            duration: Theme.animMedium
                            easing.type: Easing.OutCubic
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingLg
                            anchors.rightMargin: Theme.spacingLg
                            spacing: Theme.spacingMd

                            // Topic number badge
                            Rectangle {
                                width: 32
                                height: 32
                                radius: Theme.radiusSmall
                                color: Theme.accentDim
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: (topicItem.index + 1).toString()
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSm
                                    font.weight: Theme.fontWeightSemiBold
                                    color: Theme.accent
                                }
                            }

                            // Topic title
                            Text {
                                text: topicItem.modelData.titel || ""
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMd
                                font.weight: Theme.fontWeightMedium
                                color: Theme.textPrimary
                                Layout.fillWidth: true
                                elide: Text.ElideRight
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
                            onClicked: appStore.navigateToTopic(topicItem.modelData.id)
                            onEntered: topicItem.opacity = 0.85
                            onExited: topicItem.opacity = 1.0
                        }
                    }
                }
            }

            // Empty state
            Text {
                visible: subjectPage.topics.length === 0
                text: "Geen onderwerpen gevonden voor dit vak."
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMd
                color: Theme.textTertiary
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Bottom spacing
            Item { width: 1; height: Theme.spacingXl }
        }
    }
}
