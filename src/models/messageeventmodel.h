#ifndef LOGMESSAGEMODEL_H
#define LOGMESSAGEMODEL_H

#include "events/event.h"

#include <QtCore/QAbstractListModel>
#include <QtCore/QModelIndex>

namespace QMatrixClient
{
    class Room;
    class Connection;
}

class MessageEventModel: public QAbstractListModel
{
        Q_OBJECT
    public:
        enum EventRoles {
            EventTypeRole = Qt::UserRole + 1,
            EventIdRole,
            TimeRole,
            DateRole,
            AuthorRole,
            ContentRole,
            ContentTypeRole,
            HighlightRole,
            AvatarRole,
        };

        MessageEventModel(QObject* parent=0);
        virtual ~MessageEventModel();

        Q_INVOKABLE void setConnection(QMatrixClient::Connection* connection);
        Q_INVOKABLE void changeRoom(QMatrixClient::Room* room);
        //Q_INVOKABLE void refreshEvent(const QMatrixClient::RoomEvent* event);

        //override QModelIndex index(int row, int column, const QModelIndex& parent=QModelIndex()) const;
        //override QModelIndex parent(const QModelIndex& index) const;
        int rowCount(const QModelIndex& parent = QModelIndex()) const override;
        QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
        QHash<int, QByteArray> roleNames() const override;

    private:
        QMatrixClient::Connection* m_connection;
        QMatrixClient::Room* m_currentRoom;
};

#endif // LOGMESSAGEMODEL_H
