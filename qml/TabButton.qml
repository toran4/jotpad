import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Rectangle {
    id: root

    property int tabIndex: 0
    property string tabTitle: ""
    property bool isActive: false

    signal activated()
    signal closeRequested()
    signal titleChanged(string newTitle)

    implicitWidth: Math.max(100, Math.min(200, titleMetrics.advanceWidth + closeBtn.width + Kirigami.Units.largeSpacing * 3))
    implicitHeight: Kirigami.Units.gridUnit * 2

    TextMetrics {
        id: titleMetrics
        text: root.tabTitle
    }

    color: isActive ? Kirigami.Theme.highlightColor : "transparent"
    radius: Kirigami.Units.cornerRadius

    // Hover highlight for inactive tabs
    HoverHandler { id: hoverHandler }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Kirigami.Theme.hoverColor
        opacity: hoverHandler.hovered && !root.isActive ? 0.5 : 0
        Behavior on opacity { NumberAnimation { duration: 100 } }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: Kirigami.Units.smallSpacing * 2
            rightMargin: Kirigami.Units.smallSpacing
        }
        spacing: Kirigami.Units.smallSpacing

        // Editable label — single click activates, double-click renames
        Loader {
            id: labelLoader
            Layout.fillWidth: true
            Layout.fillHeight: true

            sourceComponent: labelComponent

            property bool editing: false

            function startEditing() {
                editing = true
                sourceComponent = editorComponent
            }
            function stopEditing() {
                editing = false
                sourceComponent = labelComponent
            }
        }

        // Close button
        QQC2.ToolButton {
            id: closeBtn
            icon.name: "tab-close"
            implicitWidth: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing * 2
            implicitHeight: implicitWidth
            opacity: hoverHandler.hovered || root.isActive ? 1 : 0
            onClicked: root.closeRequested()
            QQC2.ToolTip.text: i18n("Close tab")
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            Behavior on opacity { NumberAnimation { duration: 100 } }
        }
    }

    // ── Label component ───────────────────────────────────────────────────────
    Component {
        id: labelComponent

        Item {
            QQC2.Label {
                id: tabLabel
                anchors.fill: parent
                text: root.tabTitle
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                color: root.isActive ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
            }

            TapHandler {
                onTapped: root.activated()
                onDoubleTapped: labelLoader.startEditing()
            }
        }
    }

    // ── Inline editor component ───────────────────────────────────────────────
    Component {
        id: editorComponent

        QQC2.TextField {
            id: titleField
            text: root.tabTitle
            verticalAlignment: Text.AlignVCenter
            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                border.color: Kirigami.Theme.highlightColor
                border.width: 1
                radius: Kirigami.Units.cornerRadius / 2
            }

            Component.onCompleted: {
                forceActiveFocus()
                selectAll()
            }

            function commit() {
                const trimmed = text.trim()
                if (trimmed.length > 0)
                    root.titleChanged(trimmed)
                labelLoader.stopEditing()
            }

            Keys.onReturnPressed: commit()
            Keys.onEscapePressed: labelLoader.stopEditing()
            onEditingFinished: commit()

            // Stop single-click from propagating to tab activation
            TapHandler { }
        }
    }

    // Tap on the background of an inactive tab activates it
    TapHandler {
        enabled: !root.isActive && !labelLoader.editing
        onTapped: root.activated()
    }
}
