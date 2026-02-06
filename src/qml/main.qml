import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root

    visible: true
    width: Theme.windowWidth
    height: Theme.windowHeight
    minimumWidth: Theme.windowMinWidth
    minimumHeight: Theme.windowMinHeight
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.Window
    title: "StudyToday"

    // ── State ──────────────────────────────────────────────────────────
    property string currentPage: "home"
    property bool isMaximized: false

    function navigate(pageName) {
        if (currentPage === pageName && contentStack.depth > 0) return
        currentPage = pageName
        appStore.navigate(pageName)

        var component = pageMap[pageName]
        if (component) {
            contentStack.replace(null, component)
        }
    }

    // Map page names to component files
    property var pageMap: ({
        "home":       huisPageComp,
        "subjects":   vakkenPageComp,
        "subject":    subjectPageComp,
        "topic":      topicPageComp,
        "search":     zoekenPageComp,
        "flashcards": flashcardsPageComp,
        "notes":      notitiesPageComp,
        "timer":      timerPageComp
    })

    // Listen for appStore page changes (from navigateToSubject/navigateToTopic)
    Connections {
        target: appStore
        function onCurrentPageChanged() {
            var page = appStore.currentPage
            if (page !== root.currentPage) {
                root.currentPage = page
                var component = pageMap[page]
                if (component) {
                    contentStack.replace(null, component)
                }
            }
        }
    }

    function toggleMaximize() {
        if (isMaximized) {
            root.showNormal()
        } else {
            root.showMaximized()
        }
        isMaximized = !isMaximized
    }

    // ── Page Components ──────────────────────────────────────────────
    Component { id: huisPageComp; HuisPage {} }
    Component { id: vakkenPageComp; VakkenPage {} }
    Component { id: subjectPageComp; SubjectPage {} }
    Component { id: topicPageComp; TopicPage {} }
    Component { id: zoekenPageComp; ZoekenPage {} }
    Component { id: flashcardsPageComp; FlashcardsPage {} }
    Component { id: notitiesPageComp; NotitiesPage {} }
    Component { id: timerPageComp; TimerPage {} }

    // ── Background Layer ───────────────────────────────────────────────
    Rectangle {
        id: backgroundLayer
        anchors.fill: parent
        color: Theme.bgPrimary
        radius: root.isMaximized ? 0 : 12

        // Subtle gradient mesh
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Qt.rgba(139/255, 139/255, 245/255, 0.03) }
                GradientStop { position: 0.3; color: "transparent" }
                GradientStop { position: 0.7; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(16/255, 185/255, 129/255, 0.02) }
            }
        }

        // Top-left glow
        Rectangle {
            width: 600; height: 600; x: -200; y: -200; radius: 300
            color: "transparent"
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(139/255, 139/255, 245/255, 0.04) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // Bottom-right glow
        Rectangle {
            width: 500; height: 500
            x: parent.width - 300; y: parent.height - 300; radius: 250
            color: "transparent"
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(16/255, 185/255, 129/255, 0.03) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    // ── Title Bar Drag Area ────────────────────────────────────────────
    MouseArea {
        id: titleBarDrag
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.sidebarCollapsed
        height: Theme.titleBarHeight
        z: 10

        property point clickPos: Qt.point(0, 0)

        onPressed: function(mouse) {
            clickPos = Qt.point(mouse.x, mouse.y)
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                root.x += mouse.x - clickPos.x
                root.y += mouse.y - clickPos.y
            }
        }
        onDoubleClicked: root.toggleMaximize()
    }

    // ── Window Controls ────────────────────────────────────────────────
    WindowControls {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 12
        anchors.rightMargin: 16
        z: 20
        targetWindow: root
    }

    // ── Main Layout ────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: 0

        Sidebar {
            id: sidebar
            Layout.fillHeight: true
            currentPage: root.currentPage
            syncStatus: appStore.syncStatus
            onNavigated: function(pageName) {
                root.navigate(pageName)
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                id: contentHeaderSpacer
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Theme.titleBarHeight
            }

            // ── Update Banner ─────────────────────────────────────────
            Rectangle {
                id: updateBanner
                anchors.top: contentHeaderSpacer.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.spacingLg
                anchors.rightMargin: Theme.spacingLg
                height: visible ? 48 : 0
                visible: appUpdater.updateAvailable
                radius: Theme.radiusSmall
                color: Qt.rgba(139/255, 139/255, 245/255, 0.08)
                border.width: 1
                border.color: Qt.rgba(139/255, 139/255, 245/255, 0.15)
                z: 5

                Behavior on height {
                    NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacingLg
                    anchors.rightMargin: Theme.spacingSm
                    spacing: Theme.spacingMd

                    Text {
                        Layout.fillWidth: true
                        text: {
                            if (appUpdater.updateStatus === "downloading")
                                return "Downloaden... " + Math.round(appUpdater.downloadProgress * 100) + "%"
                            if (appUpdater.updateStatus === "ready")
                                return "Update klaar — herstart om v" + appUpdater.latestVersion + " te gebruiken"
                            if (appUpdater.updateStatus === "error")
                                return "Update mislukt"
                            return "Nieuwe versie beschikbaar: v" + appUpdater.latestVersion
                        }
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSm
                        font.weight: Theme.fontWeightMedium
                        color: Theme.accent
                        elide: Text.ElideRight
                    }

                    // Progress bar (visible during download)
                    Rectangle {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 4
                        Layout.alignment: Qt.AlignVCenter
                        radius: 2
                        color: Qt.rgba(1, 1, 1, 0.06)
                        visible: appUpdater.updateStatus === "downloading"

                        Rectangle {
                            width: parent.width * appUpdater.downloadProgress
                            height: parent.height
                            radius: 2
                            color: Theme.accent

                            Behavior on width {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    // Action button
                    Rectangle {
                        Layout.preferredWidth: btnText.width + Theme.spacingLg * 2
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        radius: Theme.radiusSmall
                        color: btnMouse.containsMouse ? Qt.rgba(139/255, 139/255, 245/255, 0.25) : Qt.rgba(139/255, 139/255, 245/255, 0.15)
                        visible: appUpdater.updateStatus === "available" || appUpdater.updateStatus === "ready"

                        Behavior on color {
                            ColorAnimation { duration: Theme.animFast }
                        }

                        Text {
                            id: btnText
                            anchors.centerIn: parent
                            text: appUpdater.updateStatus === "ready" ? "Herstarten" : "Bijwerken"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXs
                            font.weight: Theme.fontWeightSemiBold
                            color: Theme.accent
                        }

                        MouseArea {
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (appUpdater.updateStatus === "ready")
                                    appUpdater.installAndRestart()
                                else
                                    appUpdater.downloadUpdate()
                            }
                        }
                    }
                }
            }

            StackView {
                id: contentStack
                anchors.top: updateBanner.visible ? updateBanner.bottom : contentHeaderSpacer.bottom
                anchors.topMargin: updateBanner.visible ? Theme.spacingSm : 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Theme.spacingLg
                clip: true

                initialItem: huisPageComp

                pushEnter: Transition {
                    ParallelAnimation {
                        PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.animMedium; easing.type: Easing.OutCubic }
                        PropertyAnimation { property: "y"; from: 20; to: 0; duration: Theme.animMedium; easing.type: Easing.OutCubic }
                    }
                }
                pushExit: Transition {
                    ParallelAnimation {
                        PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.animNormal; easing.type: Easing.InCubic }
                        PropertyAnimation { property: "y"; from: 0; to: -10; duration: Theme.animNormal; easing.type: Easing.InCubic }
                    }
                }
                replaceEnter: Transition {
                    ParallelAnimation {
                        PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.animMedium; easing.type: Easing.OutCubic }
                        PropertyAnimation { property: "y"; from: 15; to: 0; duration: Theme.animMedium; easing.type: Easing.OutCubic }
                    }
                }
                replaceExit: Transition {
                    ParallelAnimation {
                        PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.animFast; easing.type: Easing.InCubic }
                    }
                }
            }
        }
    }

    // ── Window border ─────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: root.isMaximized ? 0 : 12
        border.width: 1
        border.color: Theme.glassBorder
        visible: !root.isMaximized
        z: 100
    }

    // Load home page on start
    Component.onCompleted: {
        root.currentPage = "home"
    }
}
