// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root

    // ── Public Properties ──────────────────────────────────────────────
    property string text: "Button"
    property string variant: "default"  // "default", "accent", "ghost"
    property string iconName: ""
    property bool enabled: true

    signal clicked()

    // ── Sizing ─────────────────────────────────────────────────────────
    implicitWidth: buttonRow.implicitWidth + Theme.spacingXl * 2
    implicitHeight: 44
    opacity: enabled ? 1.0 : 0.5

    // ── Computed Colors ────────────────────────────────────────────────
    readonly property color bgColor: {
        if (variant === "accent") return Theme.accent
        if (variant === "ghost") return "transparent"
        return Theme.glassBackground
    }

    readonly property color bgHoverColor: {
        if (variant === "accent") return Qt.lighter(Theme.accent, 1.15)
        if (variant === "ghost") return Qt.rgba(1, 1, 1, 0.04)
        return Theme.glassHover
    }

    readonly property color textColor: {
        if (variant === "accent") return "#ffffff"
        return Theme.textPrimary
    }

    readonly property color borderColor: {
        if (variant === "accent") return Qt.rgba(1, 1, 1, 0.15)
        if (variant === "ghost") return "transparent"
        return Theme.glassBorder
    }

    // ── Background ─────────────────────────────────────────────────────
    Rectangle {
        id: background
        anchors.fill: parent
        radius: Theme.radiusButton
        color: mouseArea.containsMouse && root.enabled
               ? root.bgHoverColor : root.bgColor
        border.width: variant === "ghost" ? 0 : 1
        border.color: root.borderColor

        scale: {
            if (!root.enabled) return 1.0
            if (mouseArea.pressed) return 0.98
            if (mouseArea.containsMouse) return 1.02
            return 1.0
        }

        Behavior on color {
            ColorAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
        }

        // Top highlight for glass variants
        Rectangle {
            visible: root.variant !== "ghost"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 1
            anchors.leftMargin: Theme.radiusButton
            anchors.rightMargin: Theme.radiusButton
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, root.variant === "accent" ? 0.20 : 0.08) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // ── Content ────────────────────────────────────────────────────
        RowLayout {
            id: buttonRow
            anchors.centerIn: parent
            spacing: Theme.spacingSm

            // Icon
            Text {
                visible: root.iconName !== ""
                text: root.iconName
                font.pixelSize: Theme.fontSizeMd
                color: root.textColor
                Layout.alignment: Qt.AlignVCenter
            }

            // Label
            Text {
                text: root.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSm
                font.weight: Theme.fontWeightMedium
                color: root.textColor
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    // ── Mouse Area ─────────────────────────────────────────────────────
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            if (root.enabled) {
                root.clicked()
            }
        }
    }
}
