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
                                onCloseRequested: noteModel.removeNote(index)
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
