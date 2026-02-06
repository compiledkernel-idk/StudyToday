import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root

    // ── Public Properties ──────────────────────────────────────────────
    property string currentPage: "home"
    property string syncStatus: "idle"  // "idle", "syncing", "done", "error"

    signal navigated(string pageName)

    // ── Sizing ─────────────────────────────────────────────────────────
    implicitWidth: expanded ? Theme.sidebarExpanded : Theme.sidebarCollapsed
    Layout.preferredWidth: implicitWidth

    property bool expanded: false

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    // ── Background ─────────────────────────────────────────────────────
    Rectangle {
        id: sidebarBg
        anchors.fill: parent
        color: Qt.rgba(1, 1, 1, 0.02)

        // Right border
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 1
            color: Theme.glassBorder
        }

        // Subtle gradient
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Qt.rgba(139/255, 139/255, 245/255, 0.02) }
                GradientStop { position: 0.5; color: "transparent" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    // ── Hover detection ────────────────────────────────────────────────
    HoverHandler {
        id: sidebarHover
        onHoveredChanged: root.expanded = hovered
    }

    // ── Content Column ─────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingLg
        anchors.bottomMargin: Theme.spacingLg
        spacing: 0

        // ── Logo Section ───────────────────────────────────────────────
        Item {
            Layout.preferredHeight: 56
            Layout.fillWidth: true
            Layout.bottomMargin: Theme.spacingMd

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingLg
                anchors.rightMargin: Theme.spacingLg
                spacing: Theme.spacingSm

                // Logo box
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignVCenter
                    radius: Theme.radiusSmall
                    color: Theme.accentDim

                    Text {
                        anchors.centerIn: parent
                        text: "S"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeXl
                        font.weight: Theme.fontWeightBold
                        color: Theme.accent
                    }
                }

                // App name
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: "StudyToday"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLg
                    font.weight: Theme.fontWeightSemiBold
                    color: Theme.textPrimary
                    opacity: root.expanded ? 1 : 0
                    visible: opacity > 0
                    elide: Text.ElideRight

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animNormal
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        // ── Sync Status ────────────────────────────────────────────────
        Item {
            Layout.preferredHeight: 28
            Layout.fillWidth: true
            Layout.bottomMargin: Theme.spacingSm

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingLg + 12
                anchors.rightMargin: Theme.spacingLg
                spacing: Theme.spacingSm

                // Status dot
                Rectangle {
                    Layout.preferredWidth: 8
                    Layout.preferredHeight: 8
                    Layout.alignment: Qt.AlignVCenter
                    radius: 4
                    color: {
                        switch (root.syncStatus) {
                            case "done": return Theme.correct
                            case "syncing": return Theme.warning
                            case "error": return Theme.wrong
                            default: return Theme.textTertiary
                        }
                    }

                    // Pulse animation for syncing
                    SequentialAnimation on opacity {
                        running: root.syncStatus === "syncing"
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.4; duration: 600; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
                    }
                }

                // Status text
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: {
                        switch (root.syncStatus) {
                            case "done": return "Gesynchroniseerd"
                            case "syncing": return "Synchroniseren..."
                            case "error": return "Sync fout"
                            default: return "Offline"
                        }
                    }
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeXs
                    color: Theme.textTertiary
                    opacity: root.expanded ? 1 : 0
                    visible: opacity > 0
                    elide: Text.ElideRight

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animNormal
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        // ── Primary Nav Items ──────────────────────────────────────────
        SidebarNavItem {
            pageName: "home"
            iconText: "\u2302"
            label: "Huis"
            isActive: root.currentPage === "home"
            isExpanded: root.expanded
            onClicked: root.navigated("home")
        }

        SidebarNavItem {
            pageName: "subjects"
            iconText: "\uD83D\uDCDA"
            label: "Vakken"
            isActive: root.currentPage === "subjects"
            isExpanded: root.expanded
            onClicked: root.navigated("subjects")
        }

        SidebarNavItem {
            pageName: "search"
            iconText: "\uD83D\uDD0D"
            label: "Zoeken"
            isActive: root.currentPage === "search"
            isExpanded: root.expanded
            onClicked: root.navigated("search")
        }

        // ── Divider ────────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.spacingXl

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - Theme.spacingXl * 2
                height: 1
                color: Theme.glassBorder
            }
        }

        // ── Study Nav Items ────────────────────────────────────────────
        SidebarNavItem {
            pageName: "flashcards"
            iconText: "\uD83D\uDCD1"
            label: "Flashcards"
            isActive: root.currentPage === "flashcards"
            isExpanded: root.expanded
            onClicked: root.navigated("flashcards")
        }

        SidebarNavItem {
            pageName: "notes"
            iconText: "\uD83D\uDCDD"
            label: "Notities"
            isActive: root.currentPage === "notes"
            isExpanded: root.expanded
            onClicked: root.navigated("notes")
        }

        SidebarNavItem {
            pageName: "timer"
            iconText: "\u23F1"
            label: "Timer"
            isActive: root.currentPage === "timer"
            isExpanded: root.expanded
            onClicked: root.navigated("timer")
        }

        // ── Spacer ─────────────────────────────────────────────────────
        Item {
            Layout.fillHeight: true
        }

        // ── Bottom Divider ─────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.spacingLg

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - Theme.spacingXl * 2
                height: 1
                color: Theme.glassBorder
            }
        }

        // ── Settings ───────────────────────────────────────────────────
        SidebarNavItem {
            pageName: "settings"
            iconText: "\u2699"
            label: "Instellingen"
            isActive: root.currentPage === "settings"
            isExpanded: root.expanded
            onClicked: root.navigated("settings")
        }
    }

    // ── SidebarNavItem (inline component) ──────────────────────────────
    component SidebarNavItem: Item {
        id: navItem

        property string pageName: ""
        property string iconText: ""
        property string label: ""
        property bool isActive: false
        property bool isExpanded: false

        signal clicked()

        Layout.fillWidth: true
        Layout.preferredHeight: 48

        // Active indicator bar (left edge)
        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 3
            height: navItem.isActive ? 24 : 0
            radius: 2
            color: Theme.accent
            visible: navItem.isActive

            Behavior on height {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Background highlight
        Rectangle {
            id: navBg
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingSm
            anchors.rightMargin: Theme.spacingSm
            anchors.topMargin: 2
            anchors.bottomMargin: 2
            radius: Theme.radiusSmall
            color: {
                if (navItem.isActive) return Theme.accentDim
                if (navMouseArea.containsMouse) return Qt.rgba(1, 1, 1, 0.04)
                return "transparent"
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animFast
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Content row
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingLg
            anchors.rightMargin: Theme.spacingLg
            spacing: Theme.spacingSm

            // Icon
            Text {
                Layout.preferredWidth: 32
                Layout.alignment: Qt.AlignVCenter
                text: navItem.iconText
                font.pixelSize: Theme.fontSizeLg
                horizontalAlignment: Text.AlignHCenter
                color: navItem.isActive ? Theme.accent : Theme.textSecondary

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animFast
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // Label
            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: navItem.label
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSm
                font.weight: navItem.isActive ? Theme.fontWeightMedium : Theme.fontWeightNormal
                color: navItem.isActive ? Theme.textPrimary : Theme.textSecondary
                elide: Text.ElideRight
                opacity: navItem.isExpanded ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animNormal
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animFast
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        // Click handler
        MouseArea {
            id: navMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: navItem.clicked()
        }
    }
}
