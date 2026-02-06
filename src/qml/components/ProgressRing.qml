import QtQuick
import ".."

Item {
    id: root

    // ── Public Properties ──────────────────────────────────────────────
    property real progress: 0          // 0 to 100
    property int size: 100
    property int strokeWidth: 6
    property color ringColor: Theme.accent
    property color trackColor: Theme.bgTertiary
    property bool showLabel: true
    property bool animated: true

    // ── Sizing ─────────────────────────────────────────────────────────
    implicitWidth: size
    implicitHeight: size
    width: size
    height: size

    // ── Internal animated value ────────────────────────────────────────
    property real _animatedProgress: 0

    Behavior on _animatedProgress {
        enabled: root.animated
        NumberAnimation {
            duration: Theme.animSlow
            easing.type: Easing.OutCubic
        }
    }

    onProgressChanged: {
        _animatedProgress = Math.max(0, Math.min(100, progress))
    }

    Component.onCompleted: {
        _animatedProgress = Math.max(0, Math.min(100, progress))
    }

    // ── Canvas Ring ────────────────────────────────────────────────────
    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var centerX = width / 2
            var centerY = height / 2
            var radius = (Math.min(width, height) - root.strokeWidth) / 2
            var startAngle = -Math.PI / 2  // Start from top
            var progressAngle = startAngle + (2 * Math.PI * root._animatedProgress / 100)

            // ── Track (background circle) ──────────────────────────────
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
            ctx.lineWidth = root.strokeWidth
            ctx.strokeStyle = root.trackColor.toString()
            ctx.lineCap = "round"
            ctx.stroke()

            // ── Progress arc ───────────────────────────────────────────
            if (root._animatedProgress > 0) {
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, startAngle, progressAngle)
                ctx.lineWidth = root.strokeWidth
                ctx.strokeStyle = root.ringColor.toString()
                ctx.lineCap = "round"
                ctx.stroke()
            }
        }

        // Repaint whenever animated progress changes
        Connections {
            target: root
            function on_AnimatedProgressChanged() {
                canvas.requestPaint()
            }
        }
    }

    // ── Center Label ───────────────────────────────────────────────────
    Text {
        visible: root.showLabel
        anchors.centerIn: parent
        text: Math.round(root._animatedProgress) + "%"
        font.family: Theme.fontFamily
        font.pixelSize: root.size * 0.22
        font.weight: Theme.fontWeightSemiBold
        color: Theme.textPrimary
    }
}
