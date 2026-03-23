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

    KAboutData aboutData(
        QStringLiteral("jotpad"),
        i18n("JotPad"),
        QStringLiteral("1.0"),
        i18n("A tabbed temporary notes application"),
        KAboutLicense::GPL_V3,
        i18n("© 2026")
    );
    KAboutData::setApplicationData(aboutData);
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
    engine.addImportPath(QStringLiteral("qrc:/"));
    // Make i18n() available in QML
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.rootContext()->setContextProperty(QStringLiteral("noteModel"), &noteModel);

    engine.loadFromModule("JotPad", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    int result = app.exec();

    noteModel.saveToConfig();

    return result;
}
