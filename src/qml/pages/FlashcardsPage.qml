import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: flashcardsPage

    // ── Data ─────────────────────────────────────────────────────────────
    property var allCards: collectFlashcards()
    property var cards: allCards
    property int currentIndex: 0
    property bool flipped: false

    function collectFlashcards() {
        var result = []
        var subs = appStore.subjects
        if (!subs) return result

        for (var i = 0; i < subs.length; i++) {
            var topics = subs[i].topics || []
            for (var j = 0; j < topics.length; j++) {
                var content = topics[j].content || ""
                // Extract invullen questions as flashcards
                var regex = /^:::invullen\s*\n([\s\S]*?)^:::\s*$/gm
                var match
                while ((match = regex.exec(content)) !== null) {
                    var body = match[1]
                    var vraag = "", antwoord = ""
                    var lines = body.trim().split("\n")
                    for (var k = 0; k < lines.length; k++) {
                        var line = lines[k].trim()
                        var lower = line.toLowerCase()
                        if (lower.indexOf("vraag:") === 0) vraag = line.substring(6).trim()
                        else if (lower.indexOf("antwoord:") === 0) antwoord = line.substring(9).trim()
                    }
                    if (vraag && antwoord) {
                        result.push({ vraag: vraag, antwoord: antwoord, vak: subs[i].naam })
                    }
                }
                // Also extract waar-of-niet as flashcards
                var regex2 = /^:::waar-of-niet\s*\n([\s\S]*?)^:::\s*$/gm
                var match2
                while ((match2 = regex2.exec(content)) !== null) {
                    var body2 = match2[1]
                    var vraag2 = "", antwoord2 = "", uitleg2 = ""
                    var lines2 = body2.trim().split("\n")
                    for (var k2 = 0; k2 < lines2.length; k2++) {
                        var line2 = lines2[k2].trim()
                        var lower2 = line2.toLowerCase()
                        if (lower2.indexOf("vraag:") === 0) vraag2 = line2.substring(6).trim()
                        else if (lower2.indexOf("antwoord:") === 0) antwoord2 = line2.substring(9).trim()
                        else if (lower2.indexOf("uitleg:") === 0) uitleg2 = line2.substring(7).trim()
                    }
                    if (vraag2) {
                        result.push({ vraag: vraag2, antwoord: antwoord2 + (uitleg2 ? " - " + uitleg2 : ""), vak: subs[i].naam })
                    }
                }
            }
        }
        return result
    }

    function shuffleCards() {
        var arr = allCards.slice()
        for (var i = arr.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1))
            var temp = arr[i]
            arr[i] = arr[j]
            arr[j] = temp
        }
        cards = arr
        currentIndex = 0
        flipped = false
    }

    function nextCard() {
        if (currentIndex < cards.length - 1) {
            flipped = false
            currentIndex++
        }
    }

    function prevCard() {
        if (currentIndex > 0) {
            flipped = false
            currentIndex--
        }
    }

    // ── Fade-in ──────────────────────────────────────────────────────────
    opacity: 0
    Component.onCompleted: fadeIn.start()

    OpacityAnimator {
        id: fadeIn
        target: flashcardsPage
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
                text: "Flashcards"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize2xl
                font.weight: Theme.fontWeightBold
                color: Theme.textPrimary
            }

            Text {
                text: cards.length > 0
                    ? "Klik op een kaart om het antwoord te zien"
                    : "Geen flashcards beschikbaar"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMd
                color: Theme.textSecondary
            }
        }

        // ── Card Counter ─────────────────────────────────────────────────
        Text {
            visible: cards.length > 0
            anchors.horizontalCenter: parent.horizontalCenter
            text: (currentIndex + 1) + " / " + cards.length
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLg
            font.weight: Theme.fontWeightSemiBold
            color: Theme.textSecondary
        }

        // ── Flashcard ────────────────────────────────────────────────────
        Item {
            id: cardContainer
            width: Math.min(parent.width, 560)
            height: 320
            anchors.horizontalCenter: parent.horizontalCenter
            visible: cards.length > 0

            // The card with flip rotation
            Item {
                id: flipContainer
                anchors.fill: parent

                property bool showBack: flashcardsPage.flipped

                transform: Rotation {
                    id: cardRotation
                    origin.x: flipContainer.width / 2
                    origin.y: flipContainer.height / 2
                    axis { x: 0; y: 1; z: 0 }
                    angle: 0
                }

                // Flip animation
                SequentialAnimation {
                    id: flipAnimation

                    NumberAnimation {
                        target: cardRotation
                        property: "angle"
                        to: 90
                        duration: 200
                        easing.type: Easing.InCubic
                    }

                    ScriptAction {
                        script: flipContainer.showBack = !flipContainer.showBack
                    }

                    NumberAnimation {
                        target: cardRotation
                        property: "angle"
                        to: 0
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                // Front of card
                GlassPanel {
                    anchors.fill: parent
                    radius: Theme.radiusPanel
                    visible: !flipContainer.showBack

                    Column {
                        anchors.centerIn: parent
                        anchors.margins: Theme.spacingXl
                        width: parent.width - 2 * Theme.spacingXl
                        spacing: Theme.spacingMd

                        // Subject badge
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: vakLabel.width + Theme.spacingLg * 2
                            height: 28
                            radius: Theme.radiusRound
                            color: Theme.accentDim

                            Text {
                                id: vakLabel
                                anchors.centerIn: parent
                                text: cards.length > 0 && cards[currentIndex] ? (cards[currentIndex].vak || "") : ""
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeXs
                                font.weight: Theme.fontWeightMedium
                                color: Theme.accent
                            }
                        }

                        Text {
                            width: parent.width
                            text: cards.length > 0 && cards[currentIndex] ? (cards[currentIndex].vraag || "") : ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXl
                            font.weight: Theme.fontWeightMedium
                            color: Theme.textPrimary
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Klik om te draaien"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            color: Theme.textTertiary
                            topPadding: Theme.spacingMd
                        }
                    }
                }

                // Back of card
                GlassPanel {
                    anchors.fill: parent
                    radius: Theme.radiusPanel
                    visible: flipContainer.showBack

                    // Slight accent border on back
                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radiusPanel
                        color: "transparent"
                        border.width: 1
                        border.color: Qt.rgba(139/255, 139/255, 245/255, 0.2)
                    }

                    Column {
                        anchors.centerIn: parent
                        anchors.margins: Theme.spacingXl
                        width: parent.width - 2 * Theme.spacingXl
                        spacing: Theme.spacingMd

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Antwoord"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            font.weight: Theme.fontWeightMedium
                            color: Theme.accent
                        }

                        Text {
                            width: parent.width
                            text: cards.length > 0 && cards[currentIndex] ? (cards[currentIndex].antwoord || "") : ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXl
                            font.weight: Theme.fontWeightMedium
                            color: Theme.textPrimary
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!flipAnimation.running) {
                            flashcardsPage.flipped = !flashcardsPage.flipped
                            flipAnimation.start()
                        }
                    }
                }
            }
        }

        // ── Navigation Buttons ───────────────────────────────────────────
        RowLayout {
            width: Math.min(parent.width, 560)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingLg
            visible: cards.length > 0

            GlassButton {
                text: "\u2190 Vorige"
                enabled: currentIndex > 0
                opacity: enabled ? 1.0 : 0.4
                onClicked: prevCard()
                Layout.fillWidth: true
            }

            GlassButton {
                text: "Schudden"
                onClicked: shuffleCards()
                Layout.fillWidth: true
            }

            GlassButton {
                text: "Volgende \u2192"
                enabled: currentIndex < cards.length - 1
                opacity: enabled ? 1.0 : 0.4
                onClicked: nextCard()
                Layout.fillWidth: true
            }
        }

        // ── Empty State ──────────────────────────────────────────────────
        Column {
            visible: cards.length === 0
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingMd
            topPadding: Theme.spacing3xl

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Geen flashcards"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXl
                font.weight: Theme.fontWeightSemiBold
                color: Theme.textSecondary
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Voeg vragen toe aan je onderwerpen om flashcards te genereren."
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMd
                color: Theme.textTertiary
            }
        }
    }
}
