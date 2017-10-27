/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifdef QT_QML_DEBUG
//#include <QtQuick>
#endif

#include <QtQuick>

//#include <QGuiApplication>
//#include <QQuickView>
//#include <QtQml>
#include <sailfishapp.h>

#include "connection.h"
#include "room.h"
#include "user.h"
#include "jobs/syncjob.h"
#include "models/messageeventmodel.h"
#include "models/roomlistmodel.h"
#include "settings.h"
using namespace QMatrixClient;

// https://forum.qt.io/topic/57809
Q_DECLARE_METATYPE(SyncJob*)
Q_DECLARE_METATYPE(Room*)


int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    QScopedPointer<QGuiApplication> application(SailfishApp::application(argc, argv));
    application->setApplicationName("harbour-matrix");
    application->setApplicationVersion("0.1");
    /*application->addLibraryPath(QString("%1/../share/%2/lib").arg(qApp->applicationDirPath(), qApp->applicationName()));

    QStringList args = application->arguments();
    bool daemonized = args.contains("-daemon");

    if(daemonized && !SailorGram::hasDaemonFile())
        return 0;

    QDBusConnection sessionbus = QDBusConnection::sessionBus();

    if(sessionbus.interface()->isServiceRegistered(SailorgramInterface::INTERFACE_NAME)) // Only a Single Instance is allowed
    {
        SailorgramInterface::sendWakeUp();

        if(application->hasPendingEvents())
            application->processEvents();

        return 0;
    }*/

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
    //engine->addImageProvider(QStringLiteral("thumbnail"), new ThumbnailProvider);

    view->setSource(SailfishApp::pathTo("qml/harbour-matrix.qml"));

    //if(daemonized)
    //    application->setQuitOnLastWindowClosed(false);
    //else
        view->show();

    return application->exec();

    //return SailfishApp::main(argc, argv);

}
