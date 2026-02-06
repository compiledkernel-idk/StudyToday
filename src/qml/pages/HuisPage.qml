import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: huisPage

    // ── Data ─────────────────────────────────────────────────────────────
    property var subjects: appStore.subjects
    property int totalTopics: {
        var count = 0
        if (subjects) {
            for (var i = 0; i < subjects.length; i++) {
                count += subjects[i].topics ? subjects[i].topics.length : 0
            }
        }
        return count
    }
    property int sessionCount: appStore.sessions ? appStore.sessions.length : 0
    property int totalMinutes: {
        var mins = 0
        if (appStore.sessions) {
            for (var i = 0; i < appStore.sessions.length; i++) {
                mins += appStore.sessions[i].duration || 0
            }
        }
        return mins
    }

    // ── Fade-in on load ──────────────────────────────────────────────────
    opacity: 0
    Component.onCompleted: fadeIn.start()

    OpacityAnimator {
        id: fadeIn
        target: huisPage
        from: 0; to: 1
        duration: Theme.animSlow
        easing.type: Easing.OutCubic
    }

    Flickable {
        id: scrollArea
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
            spacing: Theme.spacing2xl

            // ── Hero Section ─────────────────────────────────────────────
            Column {
                width: parent.width
                spacing: Theme.spacingSm
                topPadding: Theme.spacingXl

                Text {
                    text: appStore.greeting || "Welkom terug"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize3xl
                    font.weight: Theme.fontWeightBold
                    color: Theme.textPrimary

                    opacity: 0
                    Component.onCompleted: heroAnim.start()
                    OpacityAnimator {
                        id: heroAnim
                        target: parent
                        from: 0; to: 1
                        duration: 500
                        easing.type: Easing.OutCubic
                    }
                }

                Text {
                    text: "Klaar om te studeren? Je hebt " + huisPage.totalTopics + " onderwerpen beschikbaar."
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLg
                    font.weight: Theme.fontWeightNormal
                    color: Theme.textSecondary
                }
            }

            // ── Stats Row ────────────────────────────────────────────────
            Row {
                width: parent.width
                spacing: Theme.spacingLg

                GlassPanel {
                    width: (parent.width - 2 * Theme.spacingLg) / 3
                    height: 100
                    radius: Theme.radiusPanel

                    Column {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXs

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: huisPage.sessionCount.toString()
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize2xl
                            font.weight: Theme.fontWeightBold
                            color: Theme.accent
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Studiedagen"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            color: Theme.textSecondary
                        }
                    }
                }

                GlassPanel {
                    width: (parent.width - 2 * Theme.spacingLg) / 3
                    height: 100
                    radius: Theme.radiusPanel

                    Column {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXs

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: huisPage.totalMinutes.toString()
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize2xl
                            font.weight: Theme.fontWeightBold
                            color: Theme.accent
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Minuten gestudeerd"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            color: Theme.textSecondary
                        }
                    }
                }

                GlassPanel {
                    width: (parent.width - 2 * Theme.spacingLg) / 3
                    height: 100
                    radius: Theme.radiusPanel

                    Column {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXs

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: huisPage.totalTopics.toString()
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize2xl
                            font.weight: Theme.fontWeightBold
                            color: Theme.accent
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Onderwerpen"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            color: Theme.textSecondary
                        }
                    }
                }
            }

            // ── Jouw vakken Header ───────────────────────────────────────
            Text {
                text: "Jouw vakken"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXl
                font.weight: Theme.fontWeightSemiBold
                color: Theme.textPrimary
            }

            // ── Subject Cards Grid ───────────────────────────────────────
            GridLayout {
                width: parent.width
                columns: Math.max(2, Math.floor(parent.width / 280))
                columnSpacing: Theme.spacingLg
                rowSpacing: Theme.spacingLg

                Repeater {
                    model: huisPage.subjects

                    GlassPanel {
                        id: subjectCard
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        radius: Theme.radiusPanel

                        required property var modelData
                        required property int index

                        // Staggered fade-in
                        opacity: 0
                        Component.onCompleted: cardFadeIn.start()
                        OpacityAnimator {
                            id: cardFadeIn
                            target: subjectCard
                            from: 0; to: 1
                            duration: Theme.animSlow
                            easing.type: Easing.OutCubic
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingLg
                            spacing: Theme.spacingLg

                            // Subject icon
                            Text {
                                text: subjectCard.modelData.icon || ""
                                font.pixelSize: 36
                                Layout.alignment: Qt.AlignVCenter
                            }

                            // Name and topic count
                            Column {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: Theme.spacingXs

                                Text {
                                    text: subjectCard.modelData.naam || ""
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeLg
                                    font.weight: Theme.fontWeightSemiBold
                                    color: Theme.textPrimary
                                    width: parent.width
                                    elide: Text.ElideRight
                                }

                                Text {
                                    property int topicCount: subjectCard.modelData.topics ? subjectCard.modelData.topics.length : 0
                                    text: topicCount + (topicCount === 1 ? " onderwerp" : " onderwerpen")
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSm
                                    color: Theme.textSecondary
                                }
                            }

                            // Arrow indicator
                            Text {
                                text: "\u2192"
                                font.pixelSize: Theme.fontSizeXl
                                color: Theme.textTertiary
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: appStore.navigateToSubject(subjectCard.modelData.id)
                            onEntered: subjectCard.opacity = 0.85
                            onExited: subjectCard.opacity = 1.0
                        }
                    }
                }
            }

            // Bottom spacing
            Item { width: 1; height: Theme.spacingXl }
        }
    }
}
