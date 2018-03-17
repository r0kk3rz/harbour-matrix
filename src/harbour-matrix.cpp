#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQmlEngine>
#include <QQmlFileSelector>
#include <QQuickView>
#include <QQmlContext>
#include <QScopedPointer>
#include <QSortFilterProxyModel>
#include "connection.h"
#include "room.h"
#include "user.h"
#include "jobs/syncjob.h"
#include "jobs/joinroomjob.h"
#include "imageprovider.h"
#include "src/scriptlauncher.h"
#include "models/messageeventmodel.h"
#include "models/roomlistmodel.h"

using namespace QMatrixClient;

Q_DECLARE_METATYPE(SyncJob*)
Q_DECLARE_METATYPE(Room*)


int main(int argc, char *argv[])
{

    QScopedPointer<QGuiApplication> application(SailfishApp::application(argc, argv));
    application->setApplicationName("harbour-matrix");

    qmlRegisterType<SyncJob>(); qRegisterMetaType<SyncJob*> ("SyncJob*");
    qmlRegisterType<JoinRoomJob>(); qRegisterMetaType<JoinRoomJob*>("JoinRoomJob*");
    qmlRegisterType<Room>();    qRegisterMetaType<Room*>    ("Room*");
    qmlRegisterType<User>();    qRegisterMetaType<User*>    ("User*");
    qmlRegisterType<Connection>        ("Matrix", 1, 0, "Connection");
    qmlRegisterType<MessageEventModel> ("Matrix", 1, 0, "MessageEventModel");
    qmlRegisterType<RoomListModel>     ("Matrix", 1, 0, "RoomListModel");
    qmlRegisterType<QMatrixClient::FileTransferInfo>();
    qRegisterMetaType<QMatrixClient::FileTransferInfo>();

    Connection conn;

    RoomListModel rooms;
    rooms.setConnection(&conn);

    QSortFilterProxyModel roomsProxy;
    roomsProxy.setSortRole(RoomListModel::TagRole);
    roomsProxy.setDynamicSortFilter(true);
    roomsProxy.setSourceModel(&rooms);
    roomsProxy.sort(0, Qt::AscendingOrder);

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    QQmlEngine* engine = view->engine();
    engine->addImageProvider("mxc", new ImageProvider(&conn));
    QObject::connect(engine, SIGNAL(quit()), application.data(), SLOT(quit()));

    ScriptLauncher launcher;

    view->rootContext()->setContextProperty("scriptLauncher", &launcher);
    view->rootContext()->setContextProperty("rooms", &rooms);
    view->rootContext()->setContextProperty("roomsProxy", &roomsProxy);
    view->rootContext()->setContextProperty("connection", &conn);
    view->setSource(SailfishApp::pathTo("qml/harbour-matrix.qml"));

    view->show();

    return application->exec();

}
