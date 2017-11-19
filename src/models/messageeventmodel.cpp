/******************************************************************************
 * Copyright (C) 2015 Felix Rohrbach <kde@fxrh.de>
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

#include "messageeventmodel.h"

#include <algorithm>
#include <QtCore/QRegularExpression>
#include <QtCore/QDebug>

#include "lib/connection.h"
#include "lib/room.h"
#include "lib/user.h"
#include "lib/events/event.h"
#include "lib/events/roommessageevent.h"
#include "lib/events/roommemberevent.h"
#include "lib/events/simplestateevents.h"

MessageEventModel::MessageEventModel(QObject* parent)
    : QAbstractListModel(parent)
{
    m_currentRoom = 0;
    m_connection = 0;
}

MessageEventModel::~MessageEventModel()
{
}

void MessageEventModel::changeRoom(QMatrixClient::Room* room)
{
    beginResetModel();
    if( m_currentRoom )
    {
        m_currentRoom->disconnect(this);
    }
    m_currentRoom = room;
    if( room )
    {
        using namespace QMatrixClient;
        connect( room, &Room::aboutToAddNewMessages,
				[=](const RoomEvents& events)
                {
                    beginInsertRows(QModelIndex(), 0, events.size() - 1);
                });
        connect( room, &Room::aboutToAddHistoricalMessages,
				[=](const RoomEvents& events)
                {
                    beginInsertRows(QModelIndex(),
                                    rowCount(), rowCount() + events.size() - 1);
                });
        connect( room, &Room::addedMessages,
                 this, &MessageEventModel::endInsertRows );
    }
    endResetModel();
}

void MessageEventModel::setConnection(QMatrixClient::Connection* connection)
{
    m_connection = connection;
}

int MessageEventModel::rowCount(const QModelIndex& parent) const
{
    if( !m_currentRoom || parent.isValid() )
        return 0;
	return m_currentRoom->messageEvents().size();
}

QVariant MessageEventModel::data(const QModelIndex& index, int role) const
{
    using namespace QMatrixClient;

    if( !m_currentRoom ||
			index.row() < 0 || index.row() >= m_currentRoom->messageEvents().size() )
        return QVariant();

    RoomEvent *event = (m_currentRoom->messageEvents().end() - index.row() - 1)->event();

    if( role == Qt::DisplayRole )
    {
        if( event->type() == EventType::RoomMessage )
        {
            RoomMessageEvent* e = static_cast<RoomMessageEvent*>(event);
            User* user = m_connection->user(e->senderId());
			return QString("%1 (%2): %3").arg(user->displayname()).arg(user->id()).arg(e->plainBody());
        }
        if( event->type() == EventType::RoomMember )
        {
            RoomMemberEvent* e = static_cast<RoomMemberEvent*>(event);
            switch( e->membership() )
            {
                case MembershipType::Join:
                    return QString("%1 (%2) joined the room").arg(e->displayName(), e->userId());
                case MembershipType::Leave:
                    return QString("%1 (%2) left the room").arg(e->displayName(), e->userId());
                case MembershipType::Ban:
                    return QString("%1 (%2) was banned from the room").arg(e->displayName(), e->userId());
                case MembershipType::Invite:
                    return QString("%1 (%2) was invited to the room").arg(e->displayName(), e->userId());
                case MembershipType::Knock:
                    return QString("%1 (%2) knocked").arg(e->displayName(), e->userId());
            }
        }
        return "Unknown Event";
    }

    if( role == Qt::ToolTipRole )
    {
        return event->originalJson();
    }

    if( role == EventTypeRole )
    {
        if( event->type() == EventType::RoomMessage ) {
            RoomMessageEvent* re = static_cast<RoomMessageEvent*>(event);
            if (re->msgtype() == RoomMessageEvent::MsgType::Emote) {
                return "message.emote";
            } else if (re->msgtype() == RoomMessageEvent::MsgType::Notice) {
                return "message.notice";
            } else {
                return "message";
            }
        }
        return "other";
    }

    if( role == TimeRole )
    {
		return event->timestamp();
    }

    if( role == DateRole )
    {
        return event->timestamp().toLocalTime().date();
    }

    if( role == AuthorRole )
    {
        if( event->type() == EventType::RoomMessage )
        {
            RoomMessageEvent* e = static_cast<RoomMessageEvent*>(event);
            User *user = m_connection->user(e->senderId());
            return user->displayname();
        }
        return QVariant();
    }

    if (role == ContentTypeRole)
    {
        if (event->type() == EventType::RoomMessage)
        {
            const auto& contentType =
                static_cast<RoomMessageEvent*>(event)->mimeType().name();
            return contentType == "text/plain" ? "text/html" : contentType;
        }
        return "text/plain";
    }

    if( role == ContentRole )
    {
        if( event->type() == EventType::RoomMessage )
        {
            using namespace MessageEventContent;

            auto e = static_cast<RoomMessageEvent*>(event);
            switch (e->msgtype())
            {
            case MessageEventType::Emote:
            case MessageEventType::Text:
            case MessageEventType::Notice:
                {
                    if (e->mimeType().name() == "text/plain")
                        return e->plainBody();

                    return static_cast<const TextContent*>(e->content())->body;
                }
            case MessageEventType::Image:
                {
                    auto content = static_cast<const ImageContent*>(e->content());
                    return QUrl("image://mxc/" +
                                content->url.host() + content->url.path());
                }
            default:
                return e->plainBody();
            }
        }
        if( event->type() == EventType::RoomMember )
        {
            auto e = static_cast<RoomMemberEvent*>(event);
            // FIXME: Rewind to the name that was at the time of this event
            QString subjectName = m_currentRoom->roomMembername(e->userId());
            // The below code assumes senderName output in AuthorRole
            switch( e->membership() )
            {
                case MembershipType::Invite:
                case MembershipType::Join:
                {
                    if (!e->prev_content() ||
                            e->membership() != e->prev_content()->membership)
                    {
                        return e->membership() == MembershipType::Invite
                                ? tr("invited %1 to the room").arg(subjectName)
                                : tr("joined the room");
                    }
                    QString text {};
                    if (e->displayName() != e->prev_content()->displayName)
                    {
                        if (e->displayName().isEmpty())
                            text = tr("cleared the display name");
                        else
                            text = tr("changed the display name to %1")
                                        .arg(e->displayName());
                    }
                    if (e->avatarUrl() != e->prev_content()->avatarUrl)
                    {
                        if (!text.isEmpty())
                            text += " and ";
                        if (e->avatarUrl().isEmpty())
                            text += tr("cleared the avatar");
                        else
                            text += tr("updated the avatar");
                    }
                    return text;
                }
                case MembershipType::Leave:
                    if (e->senderId() != e->userId())
                        return tr("doesn't want %1 in the room anymore").arg(subjectName);
                    else
                        return tr("left the room");
                case MembershipType::Ban:
                    if (e->senderId() != e->userId())
                        return tr("banned %1 from the room").arg(subjectName);
                    else
                        return tr("self-banned from the room");
                case MembershipType::Knock:
                    return tr("knocked");
            }
        }
        if( event->type() == EventType::RoomAliases )
        {
            RoomAliasesEvent* e = static_cast<RoomAliasesEvent*>(event);
            return QString("Current aliases: %1").arg(e->aliases().join(", "));
        }
        if( event->type() == EventType::RoomAliases )
        {
            auto e = static_cast<RoomAliasesEvent*>(event);
            return tr("set aliases to: %1").arg(e->aliases().join(", "));
        }
        if( event->type() == EventType::RoomCanonicalAlias )
        {
            auto e = static_cast<RoomCanonicalAliasEvent*>(event);
            return tr("set the room main alias to: %1").arg(e->alias());
        }
        if( event->type() == EventType::RoomName )
        {
            auto e = static_cast<RoomNameEvent*>(event);
            return tr("set the room name to: %1").arg(e->name());
        }
        if( event->type() == EventType::RoomTopic )
        {
            auto e = static_cast<RoomTopicEvent*>(event);
            return tr("set the topic to: %1").arg(e->topic());
        }
        if( event->type() == EventType::RoomEncryption )
        {
            auto e = static_cast<EncryptionEvent*>(event);
            return tr("activated End-to-End Encryption (algorithm: %1)")
                .arg(e->algorithm());
        }
        return "Unknown Event";
    }

    if( role == HighlightRole )
    {
        if( event->type() == EventType::RoomMessage )
        {
            RoomMessageEvent* message = static_cast<RoomMessageEvent*>(event);
            User* localUser = m_currentRoom->connection()->user();

            bool m_isHighlight = message->senderId() != localUser->id() &&
                (message->plainBody().contains(localUser->id()) ||
                 message->plainBody().contains(localUser->displayname()));

            return m_isHighlight;
        }
    }

    if(role == Qt::DecorationRole)
    {
        User *user = m_connection->user(event->senderId());
        return QUrl("image://mxc/" + user->avatarUrl().host() + user->avatarUrl().path());
    }

    if(role == AvatarRole)
    {
        User *user = m_connection->user(event->senderId());
        return QUrl("image://mxc/" + user->avatarUrl().host() + user->avatarUrl().path());
    }

    if( role == EventIdRole )
    {
        return event->id();
    }

    return QVariant();
}

QHash<int, QByteArray> MessageEventModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractItemModel::roleNames();
    roles[EventTypeRole] = "eventType";
    roles[EventIdRole] = "eventId";
    roles[TimeRole] = "time";
    roles[DateRole] = "date";
    roles[AuthorRole] = "author";
    roles[ContentRole] = "content";
    roles[ContentTypeRole] = "contentType";
    roles[HighlightRole] = "highlight";
    roles[AvatarRole] = "avatar";

    return roles;
}
