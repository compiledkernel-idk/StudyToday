import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root

    // ── Public Properties ──────────────────────────────────────────────
    property string placeholderText: ""
    property alias text: textInput.text
    property string iconName: ""
    property bool readOnly: false

    signal accepted()

    // ── Sizing ─────────────────────────────────────────────────────────
    implicitWidth: 280
    implicitHeight: 48

    // ── State ──────────────────────────────────────────────────────────
    readonly property bool focused: textInput.activeFocus
    readonly property bool hasText: textInput.text.length > 0
    readonly property bool hovered: mouseArea.containsMouse

    // ── Background ─────────────────────────────────────────────────────
    Rectangle {
        id: background
        anchors.fill: parent
        radius: Theme.radiusButton
        color: root.focused ? Qt.rgba(1, 1, 1, 0.06) : Theme.glassBackground
        border.width: 1
        border.color: {
            if (root.focused) return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5)
            if (root.hovered) return Qt.rgba(1, 1, 1, 0.10)
            return Theme.glassBorder
        }

        Behavior on color {
            ColorAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }
        Behavior on border.color {
            ColorAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        // ── Focus Glow ─────────────────────────────────────────────────
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: parent.radius + 2
            color: "transparent"
            border.width: 2
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
            visible: root.focused
            opacity: root.focused ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
            }
        }

        // ── Content Row ────────────────────────────────────────────────
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingLg
            anchors.rightMargin: Theme.spacingLg
            spacing: Theme.spacingSm

            // Icon
            Text {
                visible: root.iconName !== ""
                text: root.iconName
                font.pixelSize: Theme.fontSizeMd
                color: root.focused ? Theme.accent : Theme.textSecondary
                Layout.alignment: Qt.AlignVCenter

                Behavior on color {
                    ColorAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                }
            }

            // Text Input + Placeholder
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TextInput {
                    id: textInput
                    anchors.fill: parent
                    anchors.topMargin: 1
                    verticalAlignment: TextInput.AlignVCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    color: Theme.textPrimary
                    selectionColor: Theme.accentDim
                    selectedTextColor: Theme.textPrimary
                    clip: true
                    readOnly: root.readOnly

                    onAccepted: root.accepted()
                }

                // Placeholder
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    text: root.placeholderText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    color: Theme.textTertiary
                    visible: !root.hasText && !root.focused
                    opacity: visible ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: Theme.animFast }
                    }
                }
            }

            // Clear button
            Text {
                visible: root.hasText && root.hovered
                text: "\u2715"
                font.pixelSize: Theme.fontSizeXs
                color: Theme.textSecondary
                Layout.alignment: Qt.AlignVCenter
                opacity: visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: Theme.animFast }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: textInput.text = ""
                }
            }
        }
    }

    // ── Click-to-focus ─────────────────────────────────────────────────
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.LeftButton

        onClicked: function(mouse) {
            textInput.forceActiveFocus()
            mouse.accepted = false
        }
        onPressed: function(mouse) {
            mouse.accepted = false
        }
    }
}
