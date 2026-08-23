// main.cpp — OCS QML6 host (Qt6 Quick)
// Requires qt6-declarative-dev. Without it, run: qml6 qml/Main.qml

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("ocs_qml6_engine"));
    app.setApplicationDisplayName(QStringLiteral("OCS/Node QML6 Engine"));
    app.setOrganizationName(QStringLiteral("OCS"));

    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/qt/qml/OcsDisplay/qml/Main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("OcsDisplay", "Main");
    if (engine.rootObjects().isEmpty())
        engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
