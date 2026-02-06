import QtQuick
import QtQuick.Effects
import ".."

Item {
    id: root

    // ── Public Properties ──────────────────────────────────────────────
    property bool hover: false
    property color glowColor: Theme.accent
    property string intensity: "normal"  // "subtle", "normal", "strong"
    property alias contentItem: contentContainer
    property real radius: Theme.radiusPanel

    default property alias children: contentContainer.data

    // ── Computed Values ────────────────────────────────────────────────
    readonly property real bgOpacity: {
        if (intensity === "strong") return 0.08
        if (intensity === "subtle") return 0.02
        return 0.04
    }

    readonly property real hoverBgOpacity: {
        if (intensity === "strong") return 0.12
        if (intensity === "subtle") return 0.04
        return 0.07
    }

    // ── Drop Shadow ────────────────────────────────────────────────────
    Rectangle {
        id: shadow
        anchors.fill: glassRect
        anchors.margins: -1
        radius: glassRect.radius + 1
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: hover ? 6 : 4
            radius: parent.radius
            color: Theme.shadowLight
            opacity: hover ? 0.6 : 0.3

            Behavior on opacity {
                NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
            }
            Behavior on anchors.topMargin {
                NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
            }
        }
    }

    // ── Glass Rectangle ────────────────────────────────────────────────
    Rectangle {
        id: glassRect
        anchors.fill: parent
        anchors.topMargin: hover ? -2 : 0
        radius: root.radius
        color: Qt.rgba(1, 1, 1, hover ? root.hoverBgOpacity : root.bgOpacity)
        border.width: 1
        border.color: hover ? Qt.rgba(1, 1, 1, 0.10) : Theme.glassBorder

        Behavior on color {
            ColorAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }
        Behavior on border.color {
            ColorAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }
        Behavior on anchors.topMargin {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        // ── Top Edge Highlight ─────────────────────────────────────────
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 1
            anchors.leftMargin: root.radius
            anchors.rightMargin: root.radius
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.3; color: Qt.rgba(1, 1, 1, 0.10) }
                GradientStop { position: 0.7; color: Qt.rgba(1, 1, 1, 0.10) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // ── Inner Gradient Overlay ─────────────────────────────────────
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.03) }
                GradientStop { position: 0.15; color: "transparent" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // ── Accent Glow (conditional) ──────────────────────────────────
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: hover ? 1 : 0
            border.color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.15)
            visible: hover
            opacity: hover ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
            }
        }

        // ── Content Container ──────────────────────────────────────────
        Item {
            id: contentContainer
            anchors.fill: parent
        }
    }
}
