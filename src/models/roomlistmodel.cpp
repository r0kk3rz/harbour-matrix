/******************************************************************************
 * Copyright (C) 2016 Felix Rohrbach <kde@fxrh.de>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "roomlistmodel.h"

#include <QtGui/QBrush>
#include <QtGui/QColor>
#include <QtCore/QDebug>

#include "lib/connection.h"
#include "lib/room.h"

RoomListModel::RoomListModel(QObject* parent)
    : QAbstractListModel(parent)
{
    m_connection = 0;
}

RoomListModel::~RoomListModel()
{
}

void RoomListModel::setConnection(QMatrixClient::Connection* connection)
{
    beginResetModel();
    m_connection = connection;
    m_rooms.clear();
    connect( connection, &QMatrixClient::Connection::newRoom, this, &RoomListModel::addRoom );
    for( QMatrixClient::Room* room: connection->roomMap().values() ) {
        m_rooms.append(room);
    }
    endResetModel();
}

QMatrixClient::Room* RoomListModel::roomAt(int row)
{
    return m_rooms.at(row);
}

void RoomListModel::addRoom(QMatrixClient::Room* room)
{
    beginInsertRows(QModelIndex(), m_rooms.count(), m_rooms.count());
    connect( room, &QMatrixClient::Room::namesChanged, this, [=]{ refresh(room, {Qt::DisplayRole}); });
    connect( room, &QMatrixClient::Room::unreadMessagesChanged, this, [=]{ refresh(room, {RoomEventRoles::HasUnreadRole}); });
    connect( room, &QMatrixClient::Room::highlightCountChanged, this, [=]{ refresh(room, {RoomEventRoles::HighlightCountRole}); });
    connect( room, &QMatrixClient::Room::avatarChanged, this, [=]{ refresh(room, { RoomEventRoles::AvatarRole }); });
    connect( room, &QMatrixClient::Room::tagsChanged, this, [=]{ refresh(room, { RoomEventRoles::TagRole }); });

    m_rooms.append(room);
    endInsertRows();
}

void RoomListModel::deleteRoom(QMatrixClient::Room* room)
{
    auto i = m_rooms.indexOf(room);
    if (i == -1)
        return; // Already deleted, nothing to do

    beginRemoveRows(QModelIndex(), i, i);
    m_rooms.removeAt(i);
    endRemoveRows();
}

int RoomListModel::rowCount(const QModelIndex& parent) const
{
    if( parent.isValid() )
        return 0;
    return m_rooms.count();
}

QVariant RoomListModel::data(const QModelIndex& index, int role) const
{
    if( !index.isValid() )
        return QVariant();

    if( index.row() >= m_rooms.count() )
    {
        qDebug() << "UserListModel: something wrong here...";
        return QVariant();
    }
    QMatrixClient::Room* room = m_rooms.at(index.row());
    if( role == Qt::DisplayRole )
    {
        return room->displayName();
    }
    if(role == RoomIdRole)
    {
        return room->id();
    }
    if(role == HasUnreadRole)
    {
        return room->hasUnreadMessages();
    }
    if(role == HighlightCountRole)
    {
        return room->highlightCount();
    }
    if(role == TagRole)
    {
        if(room->tagNames().count() > 0)
        {
            return room->tagNames().at(0);
        }
        else
        {
            return "rooms";
        }
    }

    return QVariant();
}

QHash<int, QByteArray> RoomListModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractItemModel::roleNames();
    roles[Qt::DisplayRole] = "display";
    roles[HasUnreadRole] = "unread";
    roles[HighlightCountRole] = "highlightcount";
    roles[AvatarRole] = "avatar";
    roles[TagRole] = "tags";
    roles[IsDirectChatRole] = "isDirectChat";
    roles[RoomIdRole] = "roomid";
    return roles;
}

void RoomListModel::refresh(QMatrixClient::Room* room, const QVector<int>& roles)
{
    int row = m_rooms.indexOf(room);
    if (row == -1)
        qCritical() << "Room" << room->id() << "not found in the room list";
    else
        emit dataChanged(index(row), index(row), roles);
}
