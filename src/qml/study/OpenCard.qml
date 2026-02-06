import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

GlassPanel {
    id: openCard
    radius: Theme.radiusPanel
    implicitHeight: cardContent.height + 2 * Theme.spacingXl

    // ── Public API ───────────────────────────────────────────────────────
    property var question: ({
        vraag: "",
        kernwoorden: []
    })

    // ── Internal state ───────────────────────────────────────────────────
    property bool answered: false
    property var foundKeywords: []      // keywords that were found in the answer
    property var missingKeywords: []    // keywords that were not found
    property int selfRating: 0         // 0-5 stars

    function checkAnswer() {
        if (answered) return
        var userText = answerArea.text.toLowerCase().trim()
        var found = []
        var missing = []
        var kw = question.kernwoorden || []

        for (var i = 0; i < kw.length; i++) {
            var keyword = kw[i].toLowerCase().trim()
            if (keyword.length > 0 && userText.indexOf(keyword) !== -1) {
                found.push(kw[i])
            } else if (keyword.length > 0) {
                missing.push(kw[i])
            }
        }

        foundKeywords = found
        missingKeywords = missing
        answered = true
    }

    function reset() {
        answered = false
        foundKeywords = []
        missingKeywords = []
        selfRating = 0
        answerArea.text = ""
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
                text: "Open vraag"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXs
                font.weight: Theme.fontWeightMedium
                color: Theme.accent
            }
        }

        // ── Question text ────────────────────────────────────────────────
        Text {
            width: parent.width
            text: openCard.question.vraag || ""
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLg
            font.weight: Theme.fontWeightMedium
            color: Theme.textPrimary
            wrapMode: Text.WordWrap
            lineHeight: 1.4
        }

        // ── Answer TextArea ──────────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: 150
            radius: Theme.radiusButton
            color: Theme.glassBackground
            border.width: 1
            border.color: answerArea.activeFocus ? Theme.accent : Theme.glassBorder

            Behavior on border.color {
                ColorAnimation { duration: Theme.animFast }
            }

            ScrollView {
                anchors.fill: parent
                anchors.margins: Theme.spacingMd

                TextArea {
                    id: answerArea
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: Theme.textPrimary
                    placeholderText: "Schrijf je antwoord hier..."
                    placeholderTextColor: Theme.textTertiary
                    wrapMode: TextEdit.WordWrap
                    enabled: !openCard.answered
                    background: Rectangle { color: "transparent" }
                    padding: 0
                }
            }
        }

        // ── Check Button ─────────────────────────────────────────────────
        Rectangle {
            visible: !openCard.answered
            width: 140
            height: 44
            radius: Theme.radiusButton
            color: Theme.accent

            Text {
                anchors.centerIn: parent
                text: "Controleer"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMd
                font.weight: Theme.fontWeightSemiBold
                color: "#111113"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: openCard.checkAnswer()
            }
        }

        // ── Keyword Results ──────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: Theme.spacingMd
            visible: openCard.answered

            opacity: openCard.answered ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: Theme.animMedium; easing.type: Easing.OutCubic }
            }

            Text {
                text: "Kernwoorden"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMd
                font.weight: Theme.fontWeightSemiBold
                color: Theme.textPrimary
            }

            Text {
                text: openCard.foundKeywords.length + " van " + (openCard.question.kernwoorden || []).length + " kernwoorden gevonden"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSm
                color: Theme.textSecondary
            }

            // Keyword badges
            Flow {
                width: parent.width
                spacing: Theme.spacingSm

                // Found keywords (green)
                Repeater {
                    model: openCard.foundKeywords

                    Rectangle {
                        width: kwFoundText.width + Theme.spacingLg * 2
                        height: 32
                        radius: Theme.radiusRound
                        color: Qt.rgba(16/255, 185/255, 129/255, 0.15)
                        border.width: 1
                        border.color: Qt.rgba(16/255, 185/255, 129/255, 0.3)

                        required property string modelData

                        Row {
                            anchors.centerIn: parent
                            spacing: Theme.spacingXs

                            Text {
                                text: "\u2713"
                                font.pixelSize: Theme.fontSizeSm
                                font.weight: Theme.fontWeightBold
                                color: Theme.correct
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                id: kwFoundText
                                text: modelData
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSm
                                font.weight: Theme.fontWeightMedium
                                color: Theme.correct
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // Missing keywords (gray)
                Repeater {
                    model: openCard.missingKeywords

                    Rectangle {
                        width: kwMissingText.width + Theme.spacingLg * 2
                        height: 32
                        radius: Theme.radiusRound
                        color: Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: Theme.glassBorder

                        required property string modelData

                        Row {
                            anchors.centerIn: parent
                            spacing: Theme.spacingXs

                            Text {
                                text: "\u2717"
                                font.pixelSize: Theme.fontSizeSm
                                font.weight: Theme.fontWeightBold
                                color: Theme.textTertiary
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                id: kwMissingText
                                text: modelData
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSm
                                font.weight: Theme.fontWeightMedium
                                color: Theme.textTertiary
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }

            // ── Separator ────────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.glassBorder
            }

            // ── Self-rating: 5 stars ─────────────────────────────────────
            Column {
                width: parent.width
                spacing: Theme.spacingSm

                Text {
                    text: "Hoe goed heb je het gedaan?"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    font.weight: Theme.fontWeightMedium
                    color: Theme.textSecondary
                }

                Row {
                    spacing: Theme.spacingSm

                    Repeater {
                        model: 5

                        Text {
                            required property int index

                            text: index < openCard.selfRating ? "\u2605" : "\u2606"
                            font.pixelSize: 28
                            color: index < openCard.selfRating ? Theme.accent : Theme.textTertiary

                            Behavior on color {
                                ColorAnimation { duration: Theme.animFast }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: openCard.selfRating = index + 1
                            }
                        }
                    }
                }

                Text {
                    visible: openCard.selfRating > 0
                    text: {
                        switch (openCard.selfRating) {
                            case 1: return "Moet nog veel oefenen"
                            case 2: return "Kan beter"
                            case 3: return "Redelijk"
                            case 4: return "Goed"
                            case 5: return "Uitstekend!"
                            default: return ""
                        }
                    }
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    color: Theme.accent
                }
            }
        }
    }
}
