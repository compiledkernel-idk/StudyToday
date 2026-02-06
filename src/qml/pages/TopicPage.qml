import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: topicPage

    // ── Data ─────────────────────────────────────────────────────────────
    property var currentTopic: {
        var tid = appStore.currentTopicId
        var subs = appStore.subjects
        if (subs) {
            for (var i = 0; i < subs.length; i++) {
                var topics = subs[i].topics
                if (topics) {
                    for (var j = 0; j < topics.length; j++) {
                        if (topics[j].id === tid) return topics[j]
                    }
                }
            }
        }
        return null
    }

    property string topicTitle: currentTopic ? (currentTopic.titel || "") : ""
    property string rawContent: currentTopic ? (currentTopic.content || "") : ""

    // ── Parsed content: markdown text and questions ───────────────────────
    // The content_parser is called from Python; we parse in QML via a helper.
    // We split the content by looking for question block markers.
    property var parsedData: parseContent(rawContent)
    property string markdownText: parsedData.markdown
    property var questions: parsedData.questions

    // ── Mode: "lezen" or "oefenen" ───────────────────────────────────────
    property string mode: "lezen"

    // ── Bookmark state ───────────────────────────────────────────────────
    property bool isBookmarked: {
        var bm = appStore.bookmarks
        var tid = appStore.currentTopicId
        if (bm) {
            for (var i = 0; i < bm.length; i++) {
                if (bm[i] === tid) return true
            }
        }
        return false
    }

    // ── Content parser (JavaScript) ──────────────────────────────────────
    function parseContent(raw) {
        if (!raw) return { markdown: "", questions: [] }

        var blockRegex = /^:::(meerkeuze|invullen|waar-of-niet|koppelen|open)\s*\n([\s\S]*?)^:::\s*$/gm
        var questions = []
        var qIndex = 0
        var markdown = raw.replace(blockRegex, function(match, type, body) {
            var q = parseQuestionBlock(type, body, qIndex)
            questions.push(q)
            var placeholder = "<!-- question-" + qIndex + " -->"
            qIndex++
            return placeholder
        })
        return { markdown: markdown.trim(), questions: questions }
    }

    function parseQuestionBlock(type, body, qid) {
        var q = { type: type, id: qid }
        var lines = body.trim().split("\n")

        if (type === "meerkeuze") {
            q.vraag = ""; q.opties = []; q.correct = 0; q.uitleg = ""
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim()
                var lower = line.toLowerCase()
                if (lower.indexOf("vraag:") === 0) {
                    q.vraag = line.substring(6).trim()
                } else if (lower.indexOf("opties:") === 0) {
                    var opts = line.substring(7).trim()
                    var parts = opts.split(/[A-Z]\)\s*/)
                    q.opties = parts.filter(function(p) { return p.trim() !== "" }).map(function(p) { return p.trim() })
                } else if (lower.indexOf("correct:") === 0) {
                    q.correct = parseInt(line.substring(8).trim()) || 0
                } else if (lower.indexOf("uitleg:") === 0) {
                    q.uitleg = line.substring(7).trim()
                }
            }
        } else if (type === "invullen") {
            q.vraag = ""; q.antwoord = ""; q.hint = ""
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim()
                var lower = line.toLowerCase()
                if (lower.indexOf("vraag:") === 0) q.vraag = line.substring(6).trim()
                else if (lower.indexOf("antwoord:") === 0) q.antwoord = line.substring(9).trim()
                else if (lower.indexOf("hint:") === 0) q.hint = line.substring(5).trim()
            }
        } else if (type === "waar-of-niet") {
            q.vraag = ""; q.antwoord = ""; q.uitleg = ""
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim()
                var lower = line.toLowerCase()
                if (lower.indexOf("vraag:") === 0) q.vraag = line.substring(6).trim()
                else if (lower.indexOf("antwoord:") === 0) q.antwoord = line.substring(9).trim().toLowerCase()
                else if (lower.indexOf("uitleg:") === 0) q.uitleg = line.substring(7).trim()
            }
        } else if (type === "koppelen") {
            q.vraag = ""; q.paren = []
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim()
                var lower = line.toLowerCase()
                if (lower.indexOf("vraag:") === 0) {
                    q.vraag = line.substring(6).trim()
                } else if (lower.indexOf("paren:") === 0) {
                    var pairsStr = line.substring(6).trim()
                    var pairs = pairsStr.split(",")
                    for (var p = 0; p < pairs.length; p++) {
                        if (pairs[p].indexOf("=") !== -1) {
                            var parts = pairs[p].split("=")
                            q.paren.push({ term: parts[0].trim(), definitie: parts[1].trim() })
                        }
                    }
                }
            }
        } else if (type === "open") {
            q.vraag = ""; q.kernwoorden = []
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim()
                var lower = line.toLowerCase()
                if (lower.indexOf("vraag:") === 0) q.vraag = line.substring(6).trim()
                else if (lower.indexOf("kernwoorden:") === 0) {
                    var kwStr = line.substring(12).trim()
                    q.kernwoorden = kwStr.split(",").filter(function(w) { return w.trim() !== "" }).map(function(w) { return w.trim() })
                }
            }
        }

        return q
    }

    // ── Fade-in ──────────────────────────────────────────────────────────
    opacity: 0
    Component.onCompleted: fadeIn.start()

    OpacityAnimator {
        id: fadeIn
        target: topicPage
        from: 0; to: 1
        duration: Theme.animSlow
        easing.type: Easing.OutCubic
    }

    Flickable {
        id: scrollView
        anchors.fill: parent
        contentHeight: contentColumn.height + Theme.spacing3xl
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            contentItem: Rectangle {
                implicitWidth: 4
                radius: 2
                color: Theme.textTertiary
                opacity: 0.5
            }
        }

        Column {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.spacingXl
            anchors.rightMargin: Theme.spacingXl
            spacing: Theme.spacingXl

            // ── Top Bar: Back + Bookmark ─────────────────────────────────
            RowLayout {
                width: parent.width
                spacing: Theme.spacingMd
                Layout.topMargin: Theme.spacingLg

                GlassButton {
                    text: "\u2190 Terug"
                    onClicked: appStore.navigateToSubject(appStore.currentSubjectId)
                }

                Item { Layout.fillWidth: true }

                // Bookmark toggle
                GlassButton {
                    text: topicPage.isBookmarked ? "\u2605 Opgeslagen" : "\u2606 Opslaan"
                    onClicked: {
                        if (topicPage.isBookmarked)
                            appStore.removeBookmark(appStore.currentTopicId)
                        else
                            appStore.addBookmark(appStore.currentTopicId)
                    }
                }
            }

            // ── Topic Title ──────────────────────────────────────────────
            Text {
                text: topicPage.topicTitle
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize2xl
                font.weight: Theme.fontWeightBold
                color: Theme.textPrimary
                width: parent.width
                wrapMode: Text.WordWrap
            }

            // ── Mode Tabs ────────────────────────────────────────────────
            Row {
                spacing: 0
                height: 44

                // "Lezen" tab
                Item {
                    width: 100
                    height: parent.height

                    Text {
                        anchors.centerIn: parent
                        text: "Lezen"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMd
                        font.weight: topicPage.mode === "lezen" ? Theme.fontWeightSemiBold : Theme.fontWeightNormal
                        color: topicPage.mode === "lezen" ? Theme.accent : Theme.textSecondary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: topicPage.mode = "lezen"
                    }
                }

                // "Oefenen" tab
                Item {
                    width: 100
                    height: parent.height

                    Text {
                        anchors.centerIn: parent
                        text: "Oefenen"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMd
                        font.weight: topicPage.mode === "oefenen" ? Theme.fontWeightSemiBold : Theme.fontWeightNormal
                        color: topicPage.mode === "oefenen" ? Theme.accent : Theme.textSecondary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: topicPage.mode = "oefenen"
                    }
                }
            }

            // ── Animated underline indicator ─────────────────────────────
            Item {
                width: 200
                height: 3

                Rectangle {
                    id: tabIndicator
                    width: 100
                    height: 3
                    radius: 2
                    color: Theme.accent
                    x: topicPage.mode === "lezen" ? 0 : 100

                    Behavior on x {
                        NumberAnimation {
                            duration: Theme.animMedium
                            easing.type: Easing.InOutCubic
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

            // ── Lezen Mode: Formatted Content ────────────────────────────
            Column {
                id: lezenContent
                width: parent.width
                spacing: Theme.spacingLg
                visible: topicPage.mode === "lezen"

                Text {
                    width: parent.width
                    text: topicPage.markdownText
                    textFormat: Text.MarkdownText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: Theme.textPrimary
                    wrapMode: Text.WordWrap
                    lineHeight: 1.6
                    linkColor: Theme.accent

                    onLinkActivated: function(link) {
                        Qt.openUrlExternally(link)
                    }
                }
            }

            // ── Oefenen Mode: Questions ──────────────────────────────────
            Column {
                id: oefenenContent
                width: parent.width
                spacing: Theme.spacingXl
                visible: topicPage.mode === "oefenen"

                Text {
                    visible: topicPage.questions.length === 0
                    text: "Geen oefenvragen beschikbaar voor dit onderwerp."
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: Theme.textTertiary
                }

                Text {
                    visible: topicPage.questions.length > 0
                    text: topicPage.questions.length + (topicPage.questions.length === 1 ? " vraag" : " vragen")
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    color: Theme.textSecondary
                }

                Repeater {
                    model: topicPage.questions

                    Loader {
                        id: questionLoader
                        width: oefenenContent.width

                        required property var modelData
                        required property int index

                        sourceComponent: {
                            var qType = modelData.type
                            if (qType === "meerkeuze") return meerkeuzeComponent
                            if (qType === "invullen") return invullenComponent
                            if (qType === "waar-of-niet") return waarOfNietComponent
                            if (qType === "koppelen") return koppelenComponent
                            if (qType === "open") return openComponent
                            return null
                        }

                        onLoaded: {
                            item.question = modelData
                        }
                    }
                }
            }

            // Bottom spacing
            Item { width: 1; height: Theme.spacing3xl }
        }
    }

    // ── Question Card Components (delegates to study/ cards) ─────────────
    Component {
        id: meerkeuzeComponent
        Loader {
            property var question
            source: "../study/MeerkeuzeCard.qml"
            width: parent ? parent.width : 0
            onLoaded: if (question) item.question = question
            onQuestionChanged: if (item) item.question = question
        }
    }

    Component {
        id: invullenComponent
        Loader {
            property var question
            source: "../study/InvullenCard.qml"
            width: parent ? parent.width : 0
            onLoaded: if (question) item.question = question
            onQuestionChanged: if (item) item.question = question
        }
    }

    Component {
        id: waarOfNietComponent
        Loader {
            property var question
            source: "../study/WaarOfNietCard.qml"
            width: parent ? parent.width : 0
            onLoaded: if (question) item.question = question
            onQuestionChanged: if (item) item.question = question
        }
    }

    Component {
        id: koppelenComponent
        Loader {
            property var question
            source: "../study/KoppelenCard.qml"
            width: parent ? parent.width : 0
            onLoaded: if (question) item.question = question
            onQuestionChanged: if (item) item.question = question
        }
    }

    Component {
        id: openComponent
        Loader {
            property var question
            source: "../study/OpenCard.qml"
            width: parent ? parent.width : 0
            onLoaded: if (question) item.question = question
            onQuestionChanged: if (item) item.question = question
        }
    }
}
