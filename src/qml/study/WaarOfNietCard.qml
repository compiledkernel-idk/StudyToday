import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

GlassPanel {
    id: waarOfNietCard
    radius: Theme.radiusPanel
    implicitHeight: cardContent.height + 2 * Theme.spacingXl

    // ── Public API ───────────────────────────────────────────────────────
    property var question: ({
        vraag: "",
        antwoord: "",  // "waar" or "niet waar"
        uitleg: ""
    })

    // ── Internal state ───────────────────────────────────────────────────
    property bool answered: false
    property string selectedAnswer: ""
    property bool isCorrect: false

    function checkAnswer(answer) {
        if (answered) return
        selectedAnswer = answer
        var correct = (question.antwoord || "").toLowerCase().trim()
        // Normalize: "waar" matches "waar", "niet waar" / "niet" / "onwaar" matches the false option
        var isTrue = (correct === "waar" || correct === "true" || correct === "ja")
        isCorrect = (answer === "waar" && isTrue) || (answer === "niet waar" && !isTrue)
        answered = true

        if (!isCorrect) {
            shakeAnim.start()
        }
    }

    function reset() {
        answered = false
        selectedAnswer = ""
        isCorrect = false
    }

    // ── Shake animation ──────────────────────────────────────────────────
    SequentialAnimation {
        id: shakeAnim

        NumberAnimation { target: buttonsRow; property: "x"; to: 8; duration: 50 }
        NumberAnimation { target: buttonsRow; property: "x"; to: -8; duration: 50 }
        NumberAnimation { target: buttonsRow; property: "x"; to: 6; duration: 50 }
        NumberAnimation { target: buttonsRow; property: "x"; to: -6; duration: 50 }
        NumberAnimation { target: buttonsRow; property: "x"; to: 0; duration: 50 }
    }

    Column {
        id: cardContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.spacingXl
        spacing: Theme.spacingLg

        // ── Badge ────────────────────────────────────────────────────────
        Rectangle {
            width: badgeText.width + Theme.spacingLg * 2
            height: 28
            radius: Theme.radiusRound
            color: Theme.accentDim

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: "Waar of niet waar"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXs
                font.weight: Theme.fontWeightMedium
                color: Theme.accent
            }
        }

        // ── Question text ────────────────────────────────────────────────
        Text {
            width: parent.width
            text: waarOfNietCard.question.vraag || ""
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLg
            font.weight: Theme.fontWeightMedium
            color: Theme.textPrimary
            wrapMode: Text.WordWrap
            lineHeight: 1.4
        }

        // ── Answer Buttons ───────────────────────────────────────────────
        Row {
            id: buttonsRow
            width: parent.width
            spacing: Theme.spacingLg

            // "Waar" button
            Rectangle {
                id: waarBtn
                width: (parent.width - Theme.spacingLg) / 2
                height: 56
                radius: Theme.radiusButton

                property bool isThisCorrect: {
                    var correct = (waarOfNietCard.question.antwoord || "").toLowerCase().trim()
                    return correct === "waar" || correct === "true" || correct === "ja"
                }

                color: {
                    if (!waarOfNietCard.answered) return Theme.glassBackground
                    if (waarBtn.isThisCorrect) return Qt.rgba(16/255, 185/255, 129/255, 0.15)
                    if (waarOfNietCard.selectedAnswer === "waar" && !waarOfNietCard.isCorrect) return Qt.rgba(239/255, 68/255, 68/255, 0.15)
                    return Theme.glassBackground
                }
                border.width: 1
                border.color: {
                    if (!waarOfNietCard.answered) return Theme.glassBorder
                    if (waarBtn.isThisCorrect) return Theme.correct
                    if (waarOfNietCard.selectedAnswer === "waar" && !waarOfNietCard.isCorrect) return Theme.wrong
                    return Theme.glassBorder
                }

                Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }

                Text {
                    anchors.centerIn: parent
                    text: "Waar"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    font.weight: Theme.fontWeightSemiBold
                    color: {
                        if (!waarOfNietCard.answered) return Theme.textPrimary
                        if (waarBtn.isThisCorrect) return Theme.correct
                        if (waarOfNietCard.selectedAnswer === "waar" && !waarOfNietCard.isCorrect) return Theme.wrong
                        return Theme.textPrimary
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: waarOfNietCard.answered ? Qt.ArrowCursor : Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: waarOfNietCard.checkAnswer("waar")
                    onEntered: {
                        if (!waarOfNietCard.answered) waarBtn.color = Theme.glassHover
                    }
                    onExited: {
                        if (!waarOfNietCard.answered) waarBtn.color = Theme.glassBackground
                    }
                }
            }

            // "Niet waar" button
            Rectangle {
                id: nietWaarBtn
                width: (parent.width - Theme.spacingLg) / 2
                height: 56
                radius: Theme.radiusButton

                property bool isThisCorrect: !waarBtn.isThisCorrect

                color: {
                    if (!waarOfNietCard.answered) return Theme.glassBackground
                    if (nietWaarBtn.isThisCorrect) return Qt.rgba(16/255, 185/255, 129/255, 0.15)
                    if (waarOfNietCard.selectedAnswer === "niet waar" && !waarOfNietCard.isCorrect) return Qt.rgba(239/255, 68/255, 68/255, 0.15)
                    return Theme.glassBackground
                }
                border.width: 1
                border.color: {
                    if (!waarOfNietCard.answered) return Theme.glassBorder
                    if (nietWaarBtn.isThisCorrect) return Theme.correct
                    if (waarOfNietCard.selectedAnswer === "niet waar" && !waarOfNietCard.isCorrect) return Theme.wrong
                    return Theme.glassBorder
                }

                Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }

                Text {
                    anchors.centerIn: parent
                    text: "Niet waar"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    font.weight: Theme.fontWeightSemiBold
                    color: {
                        if (!waarOfNietCard.answered) return Theme.textPrimary
                        if (nietWaarBtn.isThisCorrect) return Theme.correct
                        if (waarOfNietCard.selectedAnswer === "niet waar" && !waarOfNietCard.isCorrect) return Theme.wrong
                        return Theme.textPrimary
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: waarOfNietCard.answered ? Qt.ArrowCursor : Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: waarOfNietCard.checkAnswer("niet waar")
                    onEntered: {
                        if (!waarOfNietCard.answered) nietWaarBtn.color = Theme.glassHover
                    }
                    onExited: {
                        if (!waarOfNietCard.answered) nietWaarBtn.color = Theme.glassBackground
                    }
                }
            }
        }

        // ── Explanation Panel ────────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: uitlegContent.height + 2 * Theme.spacingMd
            radius: Theme.radiusSmall
            visible: waarOfNietCard.answered
            color: waarOfNietCard.isCorrect
                ? Qt.rgba(16/255, 185/255, 129/255, 0.1)
                : Qt.rgba(239/255, 68/255, 68/255, 0.1)
            border.width: 1
            border.color: waarOfNietCard.isCorrect
                ? Qt.rgba(16/255, 185/255, 129/255, 0.2)
                : Qt.rgba(239/255, 68/255, 68/255, 0.2)

            opacity: waarOfNietCard.answered ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: Theme.animMedium; easing.type: Easing.OutCubic }
            }

            Column {
                id: uitlegContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingMd
                spacing: Theme.spacingXs

                Text {
                    text: waarOfNietCard.isCorrect ? "Goed zo!" : "Helaas, dat is niet juist."
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    font.weight: Theme.fontWeightSemiBold
                    color: waarOfNietCard.isCorrect ? Theme.correct : Theme.wrong
                }

                Text {
                    visible: (waarOfNietCard.question.uitleg || "").length > 0
                    width: parent.width
                    text: waarOfNietCard.question.uitleg || ""
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
