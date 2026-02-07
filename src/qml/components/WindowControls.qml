// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root

    // ── Public Properties ──────────────────────────────────────────────
    property var targetWindow: null

    implicitWidth: controlsRow.implicitWidth
    implicitHeight: controlsRow.implicitHeight

    RowLayout {
        id: controlsRow
        spacing: 8

        // ── Minimize Button ────────────────────────────────────────────
        WindowControlButton {
            normalColor: Theme.textTertiary
            hoverColor: "#f59e0b"
            symbol: "\u2013"   // en-dash as minimize symbol
            onClicked: {
                if (root.targetWindow) root.targetWindow.showMinimized()
            }
        }

        // ── Maximize/Restore Button ────────────────────────────────────
        WindowControlButton {
            id: maximizeBtn
            normalColor: Theme.textTertiary
            hoverColor: Theme.correct
            symbol: root.targetWindow && root.targetWindow.isMaximized ? "\u29C9" : "\u25A1"
            onClicked: {
                if (root.targetWindow) root.targetWindow.toggleMaximize()
            }
        }

        // ── Close Button ───────────────────────────────────────────────
        WindowControlButton {
            normalColor: Theme.textTertiary
            hoverColor: Theme.wrong
            symbol: "\u2715"
            onClicked: {
                if (root.targetWindow) root.targetWindow.close()
            }
        }
    }

    // ── WindowControlButton (inline component) ─────────────────────────
    component WindowControlButton: Item {
        id: btn

        property color normalColor: Theme.textTertiary
        property color hoverColor: Theme.wrong
        property string symbol: ""

        signal clicked()

        implicitWidth: 14
        implicitHeight: 14
        Layout.preferredWidth: 14
        Layout.preferredHeight: 14

        Rectangle {
            id: circle
            anchors.fill: parent
            radius: 7
            color: btnMouse.containsMouse ? btn.hoverColor : btn.normalColor
            opacity: btnMouse.containsMouse ? 1.0 : 0.5

            Behavior on color {
                ColorAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
            }

            // Symbol shown on hover
            Text {
                anchors.centerIn: parent
                text: btn.symbol
                font.pixelSize: 8
                font.weight: Font.Bold
                color: "#000000"
                opacity: btnMouse.containsMouse ? 0.8 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
                }
            }
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            anchors.margins: -3  // Extend hit area slightly
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }
}
