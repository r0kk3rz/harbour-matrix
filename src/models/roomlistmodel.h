#ifndef ROOMLISTMODEL_H
#define ROOMLISTMODEL_H

#include <QtCore/QAbstractListModel>

namespace QMatrixClient
{
    class Connection;
    class Room;
}

class RoomListModel: public QAbstractListModel
{
        Q_OBJECT
    public:
        enum RoomEventRoles {
            RoomEventStateRole = Qt::UserRole + 1,
            AvatarRole
        };
        RoomListModel(QObject* parent=0);
        virtual ~RoomListModel();

        Q_INVOKABLE void setConnection(QMatrixClient::Connection* connection);
        Q_INVOKABLE QMatrixClient::Room* roomAt(int row);

        QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
        Q_INVOKABLE int rowCount(const QModelIndex& parent=QModelIndex()) const override;

        QHash<int, QByteArray> roleNames() const override;

    private slots:
        void namesChanged(QMatrixClient::Room* room);
        void unreadMessagesChanged(QMatrixClient::Room* room);
        void addRoom(QMatrixClient::Room* room);
        void highlightCountChanged(QMatrixClient::Room* room);
        void avatarChanged(QMatrixClient::Room* room, const QVector<int>& roles = {});

    private:
        QMatrixClient::Connection* m_connection;
        QList<QMatrixClient::Room*> m_rooms;
};

#endif // ROOMLISTMODEL_H
