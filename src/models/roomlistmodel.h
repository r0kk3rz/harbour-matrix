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
            HasUnreadRole = Qt::UserRole + 1,
            HighlightCountRole, 
            JoinStateRole,
            AvatarRole,
            TagRole,
            IsDirectChatRole
        };
        RoomListModel(QObject* parent=0);
        virtual ~RoomListModel();

        Q_INVOKABLE void setConnection(QMatrixClient::Connection* connection);
        Q_INVOKABLE QMatrixClient::Room* roomAt(int row);

        QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
        Q_INVOKABLE int rowCount(const QModelIndex& parent=QModelIndex()) const override;

        QHash<int, QByteArray> roleNames() const override;

    private slots:
        void addRoom(QMatrixClient::Room* room);
        void refresh(QMatrixClient::Room* room, const QVector<int>& roles = {});
        void deleteRoom(QMatrixClient::Room* room);

    private:
        QMatrixClient::Connection* m_connection;
        QList<QMatrixClient::Room*> m_rooms;
};

#endif // ROOMLISTMODEL_H
