import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: root

    title: i18n("JotPad")
    width: 800
    height: 600
    minimumWidth: 400
    minimumHeight: 300

    // Remove default page stack — we manage our own tab UI
    pageStack.visible: false

    // ── Main content ──────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Tab bar ───────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: tabRow.implicitHeight + 2
            color: Kirigami.Theme.backgroundColor

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
            }

            RowLayout {
                id: tabRow
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    leftMargin: Kirigami.Units.smallSpacing
                    rightMargin: Kirigami.Units.smallSpacing
                }
                spacing: 0

                // Scrollable tab list
                QQC2.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AsNeeded
                    QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOff
                    clip: true

                    Row {
                        id: tabListRow
                        spacing: 2
                        padding: Kirigami.Units.smallSpacing

                        Repeater {
                            model: noteModel

                            delegate: TabButton {
                                tabIndex: index
                                tabTitle: model.title
                                isActive: noteModel.currentIndex === index
                                onActivated: noteModel.currentIndex = index
                                onCloseRequested: {
                                    if (noteModel.suppressCloseWarning) {
                                        noteModel.removeNote(index)
                                    } else {
                                        closeDialog.pendingIndex = index
                                        closeDialog.open()
                                    }
                                }
                                onTitleChanged: (newTitle) => noteModel.setTitle(index, newTitle)
                            }
                        }
                    }
                }

                // "+" button
                QQC2.ToolButton {
                    icon.name: "list-add"
                    text: i18n("New Note")
                    display: QQC2.AbstractButton.IconOnly
                    QQC2.ToolTip.text: i18n("New Note")
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                    onClicked: noteModel.addNote()
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

    // ── Close confirmation dialog ─────────────────────────────────────────────
    QQC2.Dialog {
        id: closeDialog

        property int pendingIndex: -1

        parent: QQC2.Overlay.overlay
        anchors.centerIn: parent

        title: i18n("Close note")
        modal: true

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                Layout.fillWidth: true
                Layout.maximumWidth: Kirigami.Units.gridUnit * 20
                text: closeDialog.pendingIndex >= 0
                    ? i18n("The note \"%1\" will be permanently deleted and cannot be recovered.", noteModel.getTitle(closeDialog.pendingIndex))
                    : ""
                wrapMode: Text.WordWrap
            }

            QQC2.CheckBox {
                id: suppressCheck
                text: i18n("Don't show this warning again")
            }
        }

        footer: QQC2.DialogButtonBox {
            QQC2.Button {
                text: i18n("Delete")
                QQC2.DialogButtonBox.buttonRole: QQC2.DialogButtonBox.AcceptRole
            }
            QQC2.Button {
                text: i18n("Cancel")
                QQC2.DialogButtonBox.buttonRole: QQC2.DialogButtonBox.RejectRole
            }
        }

        onAccepted: {
            if (suppressCheck.checked) {
                noteModel.suppressCloseWarning = true
            }
            noteModel.removeNote(pendingIndex)
        }

        onClosed: suppressCheck.checked = false
    }

        // ── Text area ─────────────────────────────────────────────────────────
        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded

            QQC2.TextArea {
                id: textArea

                property int loadedIndex: -1

                wrapMode: TextEdit.Wrap
                placeholderText: i18n("Start typing…")
                background: Rectangle { color: Kirigami.Theme.backgroundColor }
                font.family: "monospace"
                color: Kirigami.Theme.textColor
                padding: Kirigami.Units.largeSpacing * 2

                // Load content when current tab changes
                function loadCurrent() {
                    const idx = noteModel.currentIndex
                    if (idx < 0 || idx >= noteModel.count) {
                        text = ""
                        loadedIndex = -1
                        return
                    }
                    loadedIndex = idx
                    text = noteModel.getContent(idx)
                }

                Connections {
                    target: noteModel
                    function onCurrentIndexChanged() {
                        textArea.loadCurrent()
                    }
                    function onCountChanged() {
                        // If count changed and loadedIndex is now gone, reload
                        if (noteModel.count === 0) {
                            textArea.text = ""
                            textArea.loadedIndex = -1
                        } else if (textArea.loadedIndex !== noteModel.currentIndex) {
                            textArea.loadCurrent()
                        }
                    }
                }

                onTextChanged: {
                    if (loadedIndex >= 0 && loadedIndex === noteModel.currentIndex)
                        noteModel.setContent(loadedIndex, text)
                }

                Component.onCompleted: loadCurrent()
            }
        }
    }
}
