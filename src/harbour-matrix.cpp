#ifdef QT_QML_DEBUG
//#include <QtQuick>
#endif

#include <QtQuick>
#include <sailfishapp.h>

#include "connection.h"
#include "room.h"
#include "user.h"
#include "jobs/syncjob.h"
#include "models/messageeventmodel.h"
#include "models/roomlistmodel.h"
#include "settings.h"
using namespace QMatrixClient;

Q_DECLARE_METATYPE(SyncJob*)
Q_DECLARE_METATYPE(Room*)


int main(int argc, char *argv[])
{

    QScopedPointer<QGuiApplication> application(SailfishApp::application(argc, argv));
    application->setApplicationName("harbour-matrix");
    application->setApplicationVersion("0.2");

    qmlRegisterType<SyncJob>(); qRegisterMetaType<SyncJob*> ("SyncJob*");
    qmlRegisterType<Room>();    qRegisterMetaType<Room*>    ("Room*");
    qmlRegisterType<User>();    qRegisterMetaType<User*>    ("User*");
    qmlRegisterType<Connection>        ("Matrix", 1, 0, "Connection");
    qmlRegisterType<MessageEventModel> ("Matrix", 1, 0, "MessageEventModel");
    qmlRegisterType<RoomListModel>     ("Matrix", 1, 0, "RoomListModel");
    qmlRegisterType<Settings>          ("Matrix", 1, 0, "Settings");

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    QQmlEngine* engine = view->engine();
    QObject::connect(engine, SIGNAL(quit()), application.data(), SLOT(quit()));

    view->setSource(SailfishApp::pathTo("qml/harbour-matrix.qml"));

    view->show();

    return application->exec();

}
