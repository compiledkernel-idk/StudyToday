import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

GlassPanel {
    id: invullenCard
    radius: Theme.radiusPanel
    implicitHeight: cardContent.height + 2 * Theme.spacingXl

    // ── Public API ───────────────────────────────────────────────────────
    property var question: ({
        vraag: "",
        antwoord: "",
        hint: ""
    })

    // ── Internal state ───────────────────────────────────────────────────
    property bool answered: false
    property bool isCorrect: false
    property string userAnswer: ""

    function checkAnswer() {
        if (answered) return
        userAnswer = answerInput.text.trim()
        var correct = (question.antwoord || "").trim()
        isCorrect = userAnswer.toLowerCase() === correct.toLowerCase()
        answered = true

        if (!isCorrect) {
            shakeAnim.start()
        }
    }

    function reset() {
        answered = false
        isCorrect = false
        userAnswer = ""
        answerInput.text = ""
    }

    // ── Shake animation ──────────────────────────────────────────────────
    SequentialAnimation {
        id: shakeAnim

        NumberAnimation { target: inputContainer; property: "x"; to: 8; duration: 50 }
        NumberAnimation { target: inputContainer; property: "x"; to: -8; duration: 50 }
        NumberAnimation { target: inputContainer; property: "x"; to: 6; duration: 50 }
        NumberAnimation { target: inputContainer; property: "x"; to: -6; duration: 50 }
        NumberAnimation { target: inputContainer; property: "x"; to: 0; duration: 50 }
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
                text: "Invullen"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXs
                font.weight: Theme.fontWeightMedium
                color: Theme.accent
            }
        }

        // ── Question text ────────────────────────────────────────────────
        Text {
            width: parent.width
            text: invullenCard.question.vraag || ""
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLg
            font.weight: Theme.fontWeightMedium
            color: Theme.textPrimary
            wrapMode: Text.WordWrap
            lineHeight: 1.4
        }

        // ── Hint ─────────────────────────────────────────────────────────
        Text {
            visible: (invullenCard.question.hint || "").length > 0 && !invullenCard.answered
            width: parent.width
            text: "Hint: " + (invullenCard.question.hint || "")
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSm
            font.italic: true
            color: Theme.textTertiary
            wrapMode: Text.WordWrap
        }

        // ── Input + Button Row ───────────────────────────────────────────
        Item {
            id: inputContainer
            width: parent.width
            height: 52

            RowLayout {
                anchors.fill: parent
                spacing: Theme.spacingMd

                // Answer input field
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.radiusButton
                    color: Theme.glassBackground
                    border.width: 1
                    border.color: {
                        if (!invullenCard.answered) return answerInput.activeFocus ? Theme.accent : Theme.glassBorder
                        return invullenCard.isCorrect ? Theme.correct : Theme.wrong
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: Theme.animNormal }
                    }

                    TextField {
                        id: answerInput
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingMd
                        anchors.rightMargin: Theme.spacingMd
                        verticalAlignment: TextInput.AlignVCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMd
                        color: Theme.textPrimary
                        placeholderText: "Typ je antwoord..."
                        placeholderTextColor: Theme.textTertiary
                        enabled: !invullenCard.answered
                        background: Rectangle { color: "transparent" }

                        onAccepted: invullenCard.checkAnswer()
                    }
                }

                // Check button
                Rectangle {
                    Layout.preferredWidth: 120
                    Layout.fillHeight: true
                    radius: Theme.radiusButton
                    color: invullenCard.answered ? Theme.accentDim : Theme.accent

                    Text {
                        anchors.centerIn: parent
                        text: "Controleer"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMd
                        font.weight: Theme.fontWeightSemiBold
                        color: invullenCard.answered ? Theme.accent : "#111113"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: !invullenCard.answered
                        onClicked: invullenCard.checkAnswer()
                    }
                }
            }
        }

        // ── Result ───────────────────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: resultContent.height + 2 * Theme.spacingMd
            radius: Theme.radiusSmall
            visible: invullenCard.answered
            color: invullenCard.isCorrect
                ? Qt.rgba(16/255, 185/255, 129/255, 0.1)
                : Qt.rgba(239/255, 68/255, 68/255, 0.1)
            border.width: 1
            border.color: invullenCard.isCorrect
                ? Qt.rgba(16/255, 185/255, 129/255, 0.2)
                : Qt.rgba(239/255, 68/255, 68/255, 0.2)

            opacity: invullenCard.answered ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: Theme.animMedium; easing.type: Easing.OutCubic }
            }

            Column {
                id: resultContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingMd
                spacing: Theme.spacingXs

                Text {
                    text: invullenCard.isCorrect ? "Goed zo!" : "Helaas, dat is niet juist."
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    font.weight: Theme.fontWeightSemiBold
                    color: invullenCard.isCorrect ? Theme.correct : Theme.wrong
                }

                Text {
                    visible: !invullenCard.isCorrect
                    width: parent.width
                    text: "Het juiste antwoord is: " + (invullenCard.question.antwoord || "")
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    color: Theme.textSecondary
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
