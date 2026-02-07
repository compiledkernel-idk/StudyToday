// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

GlassPanel {
    id: koppelenCard
    radius: Theme.radiusPanel
    implicitHeight: cardContent.height + 2 * Theme.spacingXl

    // ── Public API ───────────────────────────────────────────────────────
    property var question: ({
        vraag: "",
        paren: []   // [{ term: "...", definitie: "..." }, ...]
    })

    // ── Internal state ───────────────────────────────────────────────────
    property var paren: question.paren || []
    property int selectedLeftIndex: -1
    property var matchedPairs: []      // array of pair indices that are correctly matched
    property var shuffledRight: []     // shuffled definitions
    property var shuffledMap: []       // maps shuffled index -> original index
    property bool allMatched: matchedPairs.length === paren.length && paren.length > 0

    // Flash state for wrong matches
    property int flashLeftIndex: -1
    property int flashRightIndex: -1

    Component.onCompleted: shuffleDefinitions()

    function shuffleDefinitions() {
        var indices = []
        for (var i = 0; i < paren.length; i++) {
            indices.push(i)
        }
        // Fisher-Yates shuffle
        for (var j = indices.length - 1; j > 0; j--) {
            var k = Math.floor(Math.random() * (j + 1))
            var temp = indices[j]
            indices[j] = indices[k]
            indices[k] = temp
        }
        shuffledMap = indices
        var defs = []
        for (var m = 0; m < indices.length; m++) {
            defs.push(paren[indices[m]].definitie)
        }
        shuffledRight = defs
    }

    function selectLeft(index) {
        if (isMatched(index)) return
        selectedLeftIndex = index
    }

    function selectRight(shuffledIndex) {
        if (selectedLeftIndex < 0) return
        var originalRightIndex = shuffledMap[shuffledIndex]

        // Check if this right item is already matched
        for (var i = 0; i < matchedPairs.length; i++) {
            if (matchedPairs[i] === originalRightIndex) return
        }

        if (selectedLeftIndex === originalRightIndex) {
            // Correct match
            var newMatched = matchedPairs.slice()
            newMatched.push(selectedLeftIndex)
            matchedPairs = newMatched
            selectedLeftIndex = -1
        } else {
            // Wrong match - flash red
            flashLeftIndex = selectedLeftIndex
            flashRightIndex = shuffledIndex
            wrongFlashTimer.start()
            selectedLeftIndex = -1
        }
    }

    function isMatched(pairIndex) {
        for (var i = 0; i < matchedPairs.length; i++) {
            if (matchedPairs[i] === pairIndex) return true
        }
        return false
    }

    function isRightMatched(shuffledIndex) {
        var originalIndex = shuffledMap[shuffledIndex]
        return isMatched(originalIndex)
    }

    Timer {
        id: wrongFlashTimer
        interval: 500
        onTriggered: {
            koppelenCard.flashLeftIndex = -1
            koppelenCard.flashRightIndex = -1
        }
    }

    function reset() {
        selectedLeftIndex = -1
        matchedPairs = []
        flashLeftIndex = -1
        flashRightIndex = -1
        shuffleDefinitions()
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
                text: "Koppelen"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXs
                font.weight: Theme.fontWeightMedium
                color: Theme.accent
            }
        }

        // ── Question text ────────────────────────────────────────────────
        Text {
            width: parent.width
            text: koppelenCard.question.vraag || ""
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLg
            font.weight: Theme.fontWeightMedium
            color: Theme.textPrimary
            wrapMode: Text.WordWrap
            lineHeight: 1.4
        }

        // ── Instruction ──────────────────────────────────────────────────
        Text {
            visible: !koppelenCard.allMatched
            text: "Klik een term links, en dan de juiste definitie rechts."
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSm
            color: Theme.textTertiary
        }

        // ── Matching Columns ─────────────────────────────────────────────
        Row {
            width: parent.width
            spacing: Theme.spacingLg

            // Left column: terms
            Column {
                width: (parent.width - Theme.spacingLg) / 2
                spacing: Theme.spacingMd

                Repeater {
                    model: koppelenCard.paren

                    Rectangle {
                        id: leftItem
                        width: parent.width
                        height: 48
                        radius: Theme.radiusSmall

                        required property var modelData
                        required property int index

                        property bool matched: koppelenCard.isMatched(index)
                        property bool selected: koppelenCard.selectedLeftIndex === index
                        property bool flashing: koppelenCard.flashLeftIndex === index

                        color: {
                            if (matched) return Qt.rgba(16/255, 185/255, 129/255, 0.15)
                            if (flashing) return Qt.rgba(239/255, 68/255, 68/255, 0.15)
                            if (selected) return Theme.accentDim
                            return Theme.glassBackground
                        }
                        border.width: 1
                        border.color: {
                            if (matched) return Theme.correct
                            if (flashing) return Theme.wrong
                            if (selected) return Theme.accent
                            return Theme.glassBorder
                        }
                        opacity: matched ? 0.6 : 1.0

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                        Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 2 * Theme.spacingMd
                            text: leftItem.modelData.term || ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            font.weight: Theme.fontWeightMedium
                            color: leftItem.matched ? Theme.correct : Theme.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: leftItem.matched ? Qt.ArrowCursor : Qt.PointingHandCursor
                            onClicked: koppelenCard.selectLeft(leftItem.index)
                        }
                    }
                }
            }

            // Right column: shuffled definitions
            Column {
                width: (parent.width - Theme.spacingLg) / 2
                spacing: Theme.spacingMd

                Repeater {
                    model: koppelenCard.shuffledRight

                    Rectangle {
                        id: rightItem
                        width: parent.width
                        height: 48
                        radius: Theme.radiusSmall

                        required property string modelData
                        required property int index

                        property bool matched: koppelenCard.isRightMatched(index)
                        property bool flashing: koppelenCard.flashRightIndex === index

                        color: {
                            if (matched) return Qt.rgba(16/255, 185/255, 129/255, 0.15)
                            if (flashing) return Qt.rgba(239/255, 68/255, 68/255, 0.15)
                            return Theme.glassBackground
                        }
                        border.width: 1
                        border.color: {
                            if (matched) return Theme.correct
                            if (flashing) return Theme.wrong
                            return Theme.glassBorder
                        }
                        opacity: matched ? 0.6 : 1.0

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                        Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 2 * Theme.spacingMd
                            text: rightItem.modelData || ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            font.weight: Theme.fontWeightMedium
                            color: rightItem.matched ? Theme.correct : Theme.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: rightItem.matched ? Qt.ArrowCursor : Qt.PointingHandCursor
                            onClicked: koppelenCard.selectRight(rightItem.index)
                        }
                    }
                }
            }
        }

        // ── Completion message ───────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: completionText.height + 2 * Theme.spacingMd
            radius: Theme.radiusSmall
            visible: koppelenCard.allMatched
            color: Qt.rgba(16/255, 185/255, 129/255, 0.1)
            border.width: 1
            border.color: Qt.rgba(16/255, 185/255, 129/255, 0.2)

            opacity: koppelenCard.allMatched ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: Theme.animMedium; easing.type: Easing.OutCubic }
            }

            Column {
                id: completionText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingMd
                spacing: Theme.spacingXs

                Text {
                    text: "Goed gedaan!"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    font.weight: Theme.fontWeightSemiBold
                    color: Theme.correct
                }

                Text {
                    text: "Je hebt alle paren correct gekoppeld."
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    color: Theme.textSecondary
                }
            }
        }
    }
}
