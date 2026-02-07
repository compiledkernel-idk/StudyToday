// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: timerPage

    // ── State ────────────────────────────────────────────────────────────
    property string timerMode: "focus"  // "focus" or "pauze"
    property int focusDuration: 25 * 60  // 25 minutes in seconds
    property int pauzeDuration: 5 * 60   // 5 minutes in seconds
    property int totalSeconds: timerMode === "focus" ? focusDuration : pauzeDuration
    property int remainingSeconds: totalSeconds
    property bool running: false
    property real progress: totalSeconds > 0 ? (1.0 - remainingSeconds / totalSeconds) : 0

    // ── Timer ────────────────────────────────────────────────────────────
    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: timerPage.running

        onTriggered: {
            if (timerPage.remainingSeconds > 0) {
                timerPage.remainingSeconds--
                timerCanvas.requestPaint()
            }
            if (timerPage.remainingSeconds <= 0) {
                timerPage.running = false
                timerPage.onTimerComplete()
            }
        }
    }

    // ── Glow pulse animation while running ───────────────────────────────
    SequentialAnimation {
        id: glowPulse
        running: timerPage.running
        loops: Animation.Infinite

        NumberAnimation {
            target: glowCircle
            property: "opacity"
            from: 0.15; to: 0.35
            duration: 1200
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: glowCircle
            property: "opacity"
            from: 0.35; to: 0.15
            duration: 1200
            easing.type: Easing.InOutSine
        }
    }

    function onTimerComplete() {
        if (timerMode === "focus") {
            // Log study session
            appStore.addSession(appStore.currentSubjectId || 0, focusDuration / 60)
        }
    }

    function startPause() {
        running = !running
    }

    function resetTimer() {
        running = false
        remainingSeconds = totalSeconds
        timerCanvas.requestPaint()
    }

    function switchMode(newMode) {
        if (timerMode === newMode) return
        running = false
        timerMode = newMode
        remainingSeconds = totalSeconds
        timerCanvas.requestPaint()
    }

    function formatTime(seconds) {
        var m = Math.floor(seconds / 60)
        var s = seconds % 60
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
    }

    // ── Fade-in ──────────────────────────────────────────────────────────
    opacity: 0
    Component.onCompleted: fadeIn.start()

    OpacityAnimator {
        id: fadeIn
        target: timerPage
        from: 0; to: 1
        duration: Theme.animSlow
        easing.type: Easing.OutCubic
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacingXl
        spacing: Theme.spacingXl

        // ── Header ───────────────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: Theme.spacingSm

            Text {
                text: "Timer"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize2xl
                font.weight: Theme.fontWeightBold
                color: Theme.textPrimary
            }

            Text {
                text: "Gebruik de Pomodoro-techniek om gefocust te studeren"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMd
                color: Theme.textSecondary
            }
        }

        // ── Mode Tabs ────────────────────────────────────────────────────
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            // Focus tab
            Rectangle {
                width: 120
                height: 40
                radius: Theme.radiusSmall
                color: timerPage.timerMode === "focus" ? Theme.accentDim : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "Focus"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    font.weight: timerPage.timerMode === "focus" ? Theme.fontWeightSemiBold : Theme.fontWeightNormal
                    color: timerPage.timerMode === "focus" ? Theme.accent : Theme.textSecondary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: timerPage.switchMode("focus")
                }

                Behavior on color {
                    ColorAnimation { duration: Theme.animFast }
                }
            }

            // Pauze tab
            Rectangle {
                width: 120
                height: 40
                radius: Theme.radiusSmall
                color: timerPage.timerMode === "pauze" ? Theme.accentDim : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "Pauze"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    font.weight: timerPage.timerMode === "pauze" ? Theme.fontWeightSemiBold : Theme.fontWeightNormal
                    color: timerPage.timerMode === "pauze" ? Theme.accent : Theme.textSecondary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: timerPage.switchMode("pauze")
                }

                Behavior on color {
                    ColorAnimation { duration: Theme.animFast }
                }
            }
        }

        // ── Circular Timer Display ───────────────────────────────────────
        Item {
            width: 280
            height: 280
            anchors.horizontalCenter: parent.horizontalCenter

            // Glow circle behind (pulses when running)
            Rectangle {
                id: glowCircle
                anchors.centerIn: parent
                width: 260
                height: 260
                radius: 130
                color: "transparent"
                border.width: 2
                border.color: Theme.accent
                opacity: 0.15

                Behavior on opacity {
                    NumberAnimation { duration: 300 }
                }
            }

            // Canvas for the timer ring
            Canvas {
                id: timerCanvas
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d")
                    var cx = width / 2
                    var cy = height / 2
                    var radius = Math.min(cx, cy) - 20
                    var lineWidth = 8

                    ctx.clearRect(0, 0, width, height)

                    // Background ring (track)
                    ctx.beginPath()
                    ctx.arc(cx, cy, radius, 0, 2 * Math.PI)
                    ctx.lineWidth = lineWidth
                    ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.06)
                    ctx.stroke()

                    // Progress ring
                    if (timerPage.progress > 0) {
                        var startAngle = -Math.PI / 2
                        var endAngle = startAngle + (2 * Math.PI * timerPage.progress)

                        ctx.beginPath()
                        ctx.arc(cx, cy, radius, startAngle, endAngle)
                        ctx.lineWidth = lineWidth
                        ctx.lineCap = "round"
                        ctx.strokeStyle = Theme.accent
                        ctx.stroke()
                    }
                }

                // Repaint when progress changes
                Connections {
                    target: timerPage
                    function onProgressChanged() {
                        timerCanvas.requestPaint()
                    }
                }
            }

            // Time display in center
            Column {
                anchors.centerIn: parent
                spacing: Theme.spacingXs

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: timerPage.formatTime(timerPage.remainingSeconds)
                    font.family: Theme.fontFamily
                    font.pixelSize: 56
                    font.weight: Theme.fontWeightBold
                    color: Theme.textPrimary
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: timerPage.timerMode === "focus" ? "Focus" : "Pauze"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    color: Theme.textSecondary
                }
            }
        }

        // ── Control Buttons ──────────────────────────────────────────────
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingLg

            // Start / Pause button
            Rectangle {
                width: 140
                height: 48
                radius: Theme.radiusButton
                color: timerPage.running ? Theme.accentDim : Theme.accent

                Text {
                    anchors.centerIn: parent
                    text: timerPage.running ? "Pauzeer" : "Start"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    font.weight: Theme.fontWeightSemiBold
                    color: timerPage.running ? Theme.accent : "#111113"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: timerPage.startPause()
                }

                Behavior on color {
                    ColorAnimation { duration: Theme.animFast }
                }
            }

            // Reset button (ghost style)
            Rectangle {
                width: 140
                height: 48
                radius: Theme.radiusButton
                color: "transparent"
                border.width: 1
                border.color: Theme.glassBorder

                Text {
                    anchors.centerIn: parent
                    text: "Reset"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    font.weight: Theme.fontWeightMedium
                    color: Theme.textSecondary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: timerPage.resetTimer()
                    onEntered: parent.border.color = Theme.textTertiary
                    onExited: parent.border.color = Theme.glassBorder
                }
            }
        }

        // ── Session info ─────────────────────────────────────────────────
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Na elke focus-sessie wordt je studietijd automatisch opgeslagen."
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSm
            color: Theme.textTertiary
        }
    }
}
