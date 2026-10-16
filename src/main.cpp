#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QProcessEnvironment>

#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>

#include "notemodel.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    // Must happen before any i18n() call, otherwise the strings passed to the
    // KAboutData constructor below are translated without a domain and are
    // silently emitted untranslated.
    KLocalizedString::setApplicationDomain(QByteArrayLiteral("jotpad"));

    KAboutData aboutData(
        QStringLiteral("jotpad"),
        i18n("JotPad"),
        QStringLiteral("1.0"),
        i18n("A tabbed temporary notes application"),
        KAboutLicense::GPL_V3,
        i18n("© 2026")
    );
    KAboutData::setApplicationData(aboutData);
    // Associates running windows (Wayland app-id / X11 WM_CLASS) with
    // jotpad.desktop so GNOME and KDE show the correct icon in
    // task managers/docks instead of a generic one.
    app.setDesktopFileName(QStringLiteral("jotpad"));
    app.setWindowIcon(QIcon::fromTheme(QStringLiteral("jotpad")));

    const bool devMode = QProcessEnvironment::systemEnvironment().value(QStringLiteral("JOTPAD_DEV")) == QStringLiteral("1");
    const QString configName = devMode ? QStringLiteral("jotpadrc-dev") : QStringLiteral("jotpadrc");
    NoteModel noteModel(configName);
    noteModel.loadFromConfig();

    // If no notes were saved, start with one empty note
    if (noteModel.count() == 0) {
        noteModel.addNote();
    }

    QQmlApplicationEngine engine;
    // Make i18n() available in QML
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.rootContext()->setContextProperty(QStringLiteral("noteModel"), &noteModel);

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    int result = app.exec();

    noteModel.saveToConfig();

    return result;
}
