// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

pragma Singleton
import QtQuick

QtObject {
    // ── Background Colors ──────────────────────────────────────────────
    readonly property color bgPrimary:   "#111113"
    readonly property color bgSecondary: "#1a1a1e"
    readonly property color bgTertiary:  "#232328"

    // ── Text Colors ────────────────────────────────────────────────────
    readonly property color textPrimary:   "#e8e8ea"
    readonly property color textSecondary: "#6e6e76"
    readonly property color textTertiary:  "#4a4a52"

    // ── Accent Colors ──────────────────────────────────────────────────
    readonly property color accent:    "#8b8bf5"
    readonly property color accentDim: Qt.rgba(139/255, 139/255, 245/255, 0.15)

    // ── Semantic Colors ────────────────────────────────────────────────
    readonly property color correct: "#10b981"
    readonly property color wrong:   "#ef4444"
    readonly property color warning: "#f59e0b"

    // ── Glass Morphism ─────────────────────────────────────────────────
    readonly property color glassBackground:  Qt.rgba(1, 1, 1, 0.04)
    readonly property color glassBorder:      Qt.rgba(1, 1, 1, 0.06)
    readonly property color glassHighlight:   Qt.rgba(1, 1, 1, 0.08)
    readonly property color glassHover:       Qt.rgba(1, 1, 1, 0.07)

    // ── Shadow Colors ──────────────────────────────────────────────────
    readonly property color shadowLight: Qt.rgba(0, 0, 0, 0.15)
    readonly property color shadowMedium: Qt.rgba(0, 0, 0, 0.30)
    readonly property color shadowHeavy: Qt.rgba(0, 0, 0, 0.50)

    // ── Font Family ────────────────────────────────────────────────────
    readonly property string fontFamily: "Inter"

    // ── Font Sizes ─────────────────────────────────────────────────────
    readonly property int fontSizeXs:    11
    readonly property int fontSizeSm:    13
    readonly property int fontSizeMd:    15
    readonly property int fontSizeLg:    18
    readonly property int fontSizeXl:    24
    readonly property int fontSize2xl:   32
    readonly property int fontSize3xl:   40

    // ── Font Weights ───────────────────────────────────────────────────
    readonly property int fontWeightNormal:   Font.Normal
    readonly property int fontWeightMedium:   Font.Medium
    readonly property int fontWeightSemiBold: Font.DemiBold
    readonly property int fontWeightBold:     Font.Bold

    // ── Border Radii ───────────────────────────────────────────────────
    readonly property int radiusPanel:  16
    readonly property int radiusButton: 12
    readonly property int radiusSmall:  8
    readonly property int radiusRound:  999

    // ── Spacing ────────────────────────────────────────────────────────
    readonly property int spacingXs:  4
    readonly property int spacingSm:  8
    readonly property int spacingMd:  12
    readonly property int spacingLg:  16
    readonly property int spacingXl:  24
    readonly property int spacing2xl: 32
    readonly property int spacing3xl: 48

    // ── Animation Durations (ms) ───────────────────────────────────────
    readonly property int animFast:    150
    readonly property int animNormal:  200
    readonly property int animMedium:  300
    readonly property int animSlow:    400

    // ── Sidebar Dimensions ─────────────────────────────────────────────
    readonly property int sidebarCollapsed: 72
    readonly property int sidebarExpanded:  240

    // ── Window Dimensions ──────────────────────────────────────────────
    readonly property int windowWidth:     1280
    readonly property int windowHeight:    800
    readonly property int windowMinWidth:  900
    readonly property int windowMinHeight: 600
    readonly property int titleBarHeight:  40
}
