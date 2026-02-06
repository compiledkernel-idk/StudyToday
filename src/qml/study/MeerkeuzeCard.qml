import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

GlassPanel {
    id: meerkeuzeCard
    radius: Theme.radiusPanel
    implicitHeight: cardContent.height + 2 * Theme.spacingXl

    // ── Public API ───────────────────────────────────────────────────────
    property var question: ({
        vraag: "",
        opties: [],
        correct: 0,
        uitleg: ""
    })

    // ── Internal state ───────────────────────────────────────────────────
    property bool answered: false
    property int selectedOption: -1
    property bool isCorrect: false

    function checkAnswer(index) {
        if (answered) return
        selectedOption = index
        isCorrect = (index === question.correct)
        answered = true

        if (!isCorrect) {
            shakeAnimation.start()
        }
    }

    function reset() {
        answered = false
        selectedOption = -1
        isCorrect = false
        explanationPanel.opacity = 0
    }

    Column {
        id: cardContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.spacingXl
        spacing: Theme.spacingLg

        // ── Question type badge ──────────────────────────────────────────
        Rectangle {
            width: badgeLabel.width + Theme.spacingLg * 2
            height: 28
            radius: Theme.radiusRound
            color: Theme.accentDim

            Text {
                id: badgeLabel
                anchors.centerIn: parent
                text: "Meerkeuze"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXs
                font.weight: Theme.fontWeightMedium
                color: Theme.accent
            }
        }

        // ── Question text ────────────────────────────────────────────────
        Text {
            width: parent.width
            text: meerkeuzeCard.question.vraag || ""
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLg
            font.weight: Theme.fontWeightMedium
            color: Theme.textPrimary
            wrapMode: Text.WordWrap
            lineHeight: 1.4
        }

        // ── Option buttons ───────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: Theme.spacingMd

            Repeater {
                model: meerkeuzeCard.question.opties || []

                Rectangle {
                    id: optionRect
                    width: parent.width
                    height: 52
                    radius: Theme.radiusButton

                    required property string modelData
                    required property int index

                    property string label: String.fromCharCode(65 + index)  // A, B, C, D

                    // ── Determine color based on state ───────────────────
                    property color defaultBg: Theme.glassBackground
                    property color currentBg: {
                        if (!meerkeuzeCard.answered) return defaultBg
                        if (index === meerkeuzeCard.question.correct) return Qt.rgba(16/255, 185/255, 129/255, 0.15)
                        if (index === meerkeuzeCard.selectedOption && !meerkeuzeCard.isCorrect) return Qt.rgba(239/255, 68/255, 68/255, 0.15)
                        return defaultBg
                    }

                    property color borderColor: {
                        if (!meerkeuzeCard.answered) return Theme.glassBorder
                        if (index === meerkeuzeCard.question.correct) return Theme.correct
                        if (index === meerkeuzeCard.selectedOption && !meerkeuzeCard.isCorrect) return Theme.wrong
                        return Theme.glassBorder
                    }

                    color: currentBg
                    border.width: 1
                    border.color: borderColor

                    Behavior on color {
                        ColorAnimation { duration: Theme.animNormal }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: Theme.animNormal }
                    }

                    // Shake animation for wrong answers
                    SequentialAnimation {
                        id: shakeAnimation
                        running: false

                        NumberAnimation {
                            target: optionRect
                            property: "x"
                            to: meerkeuzeCard.selectedOption === optionRect.index ? 8 : 0
                            duration: 50
                        }
                        NumberAnimation {
                            target: optionRect
                            property: "x"
                            to: meerkeuzeCard.selectedOption === optionRect.index ? -8 : 0
                            duration: 50
                        }
                        NumberAnimation {
                            target: optionRect
                            property: "x"
                            to: meerkeuzeCard.selectedOption === optionRect.index ? 6 : 0
                            duration: 50
                        }
                        NumberAnimation {
                            target: optionRect
                            property: "x"
                            to: meerkeuzeCard.selectedOption === optionRect.index ? -6 : 0
                            duration: 50
                        }
                        NumberAnimation {
                            target: optionRect
                            property: "x"
                            to: 0
                            duration: 50
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingLg
                        anchors.rightMargin: Theme.spacingLg
                        spacing: Theme.spacingMd

                        // Label badge (A, B, C, D)
                        Rectangle {
                            width: 28
                            height: 28
                            radius: 14
                            color: {
                                if (!meerkeuzeCard.answered) return Theme.accentDim
                                if (optionRect.index === meerkeuzeCard.question.correct) return Theme.correct
                                if (optionRect.index === meerkeuzeCard.selectedOption && !meerkeuzeCard.isCorrect) return Theme.wrong
                                return Theme.accentDim
                            }
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: optionRect.label
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSm
                                font.weight: Theme.fontWeightSemiBold
                                color: {
                                    if (!meerkeuzeCard.answered) return Theme.accent
                                    if (optionRect.index === meerkeuzeCard.question.correct) return "#fff"
                                    if (optionRect.index === meerkeuzeCard.selectedOption && !meerkeuzeCard.isCorrect) return "#fff"
                                    return Theme.accent
                                }
                            }

                            Behavior on color {
                                ColorAnimation { duration: Theme.animNormal }
                            }
                        }

                        // Option text
                        Text {
                            text: optionRect.modelData
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMd
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        // Check/Cross icon after answer
                        Text {
                            visible: meerkeuzeCard.answered && (optionRect.index === meerkeuzeCard.question.correct || optionRect.index === meerkeuzeCard.selectedOption)
                            text: optionRect.index === meerkeuzeCard.question.correct ? "\u2713" : "\u2717"
                            font.pixelSize: Theme.fontSizeLg
                            font.weight: Theme.fontWeightBold
                            color: optionRect.index === meerkeuzeCard.question.correct ? Theme.correct : Theme.wrong
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: meerkeuzeCard.answered ? Qt.ArrowCursor : Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: meerkeuzeCard.checkAnswer(optionRect.index)
                        onEntered: {
                            if (!meerkeuzeCard.answered) {
                                optionRect.color = Theme.glassHover
                            }
                        }
                        onExited: {
                            if (!meerkeuzeCard.answered) {
                                optionRect.color = optionRect.defaultBg
                            }
                        }
                    }
                }
            }
        }

        // ── Explanation Panel (slides in from bottom) ────────────────────
        Rectangle {
            id: explanationPanel
            width: parent.width
            height: uitlegText.height + 2 * Theme.spacingMd
            radius: Theme.radiusSmall
            color: meerkeuzeCard.isCorrect
                ? Qt.rgba(16/255, 185/255, 129/255, 0.1)
                : Qt.rgba(239/255, 68/255, 68/255, 0.1)
            border.width: 1
            border.color: meerkeuzeCard.isCorrect
                ? Qt.rgba(16/255, 185/255, 129/255, 0.2)
                : Qt.rgba(239/255, 68/255, 68/255, 0.2)
            visible: meerkeuzeCard.answered && (meerkeuzeCard.question.uitleg || "").length > 0
            opacity: meerkeuzeCard.answered ? 1.0 : 0.0
            clip: true

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animMedium
                    easing.type: Easing.OutCubic
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacingMd
                spacing: Theme.spacingXs

                Text {
                    text: meerkeuzeCard.isCorrect ? "Goed zo!" : "Helaas, dat is niet juist."
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    font.weight: Theme.fontWeightSemiBold
                    color: meerkeuzeCard.isCorrect ? Theme.correct : Theme.wrong
                }

                Text {
                    id: uitlegText
                    width: parent.width
                    text: meerkeuzeCard.question.uitleg || ""
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    color: Theme.textSecondary
                    wrapMode: Text.WordWrap
                    lineHeight: 1.4
                }
            }
        }
    }
}
