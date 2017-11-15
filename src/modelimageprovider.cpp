#include "modelimageprovider.h"

#include <QStandardPaths>
#include <QFile>
#include <QDir>

#include "lib/room.h"


ModelImageProvider::ModelImageProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap) {}

QPixmap ModelImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    qulonglong d = id.toULongLong();
    if (d) {
        QMatrixClient::Room* room = reinterpret_cast<QMatrixClient::Room *>(d);
        //QPixmap * avatar = new QPixmap();
        qDebug() << "hi! image here " << id;

        auto avatar = room->avatar(16, 16);
        if (!avatar.isNull())
            return avatar;
        else return QPixmap();
        /*switch( room->joinState() )
        {
            case QMatrixClient::JoinState::Join:
                return QIcon(":/irc-channel-joined.svg");
            case QMatrixClient::JoinState::Invite:
                return QIcon(":/irc-channel-invited.svg");
            case QMatrixClient::JoinState::Leave:
                return QIcon(":/irc-channel-parted.svg");
        }*/

        //return room->avatar(16, 16);
    } else {
        return QPixmap();
    }
}
