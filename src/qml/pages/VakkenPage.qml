import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: vakkenPage

    property var subjects: appStore.subjects

    // ── Fade-in ──────────────────────────────────────────────────────────
    opacity: 0
    Component.onCompleted: fadeIn.start()

    OpacityAnimator {
        id: fadeIn
        target: vakkenPage
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
            spacing: Theme.spacing2xl

            // ── Header ───────────────────────────────────────────────────
            Column {
                width: parent.width
                spacing: Theme.spacingSm
                topPadding: Theme.spacingXl

                Text {
                    text: "Vakken"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize3xl
                    font.weight: Theme.fontWeightBold
                    color: Theme.textPrimary
                }

                Text {
                    text: "Kies een vak om te beginnen met studeren."
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLg
                    font.weight: Theme.fontWeightNormal
                    color: Theme.textSecondary
                }
            }

            // ── Subject Grid ─────────────────────────────────────────────
            GridLayout {
                width: parent.width
                columns: Math.max(2, Math.floor(parent.width / 320))
                columnSpacing: Theme.spacingLg
                rowSpacing: Theme.spacingLg

                Repeater {
                    model: vakkenPage.subjects

                    GlassPanel {
                        id: vakCard
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        radius: Theme.radiusPanel

                        required property var modelData
                        required property int index

                        // Staggered fade-in
                        opacity: 0
                        Component.onCompleted: vakFadeIn.start()
                        OpacityAnimator {
                            id: vakFadeIn
                            target: vakCard
                            from: 0; to: 1
                            duration: Theme.animSlow
                            easing.type: Easing.OutCubic
                        }

                        Column {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingXl
                            spacing: Theme.spacingMd

                            // Icon + Progress row
                            RowLayout {
                                width: parent.width
                                spacing: Theme.spacingLg

                                Text {
                                    text: vakCard.modelData.icon || ""
                                    font.pixelSize: 44
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Item { Layout.fillWidth: true }

                                ProgressRing {
                                    size: 48
                                    strokeWidth: 4
                                    progress: 0
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            Item { width: 1; height: Theme.spacingXs }

                            // Subject name
                            Text {
                                text: vakCard.modelData.naam || ""
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeXl
                                font.weight: Theme.fontWeightSemiBold
                                color: Theme.textPrimary
                                width: parent.width
                                elide: Text.ElideRight
                            }

                            // Topic count
                            Text {
                                property int topicCount: vakCard.modelData.topics ? vakCard.modelData.topics.length : 0
                                text: topicCount + (topicCount === 1 ? " onderwerp" : " onderwerpen")
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSm
                                color: Theme.textSecondary
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: appStore.navigateToSubject(vakCard.modelData.id)
                            onEntered: vakCard.scale = 1.02
                            onExited: vakCard.scale = 1.0

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Theme.animFast
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: Theme.animFast
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }

            // Bottom spacing
            Item { width: 1; height: Theme.spacingXl }
        }
    }
}
