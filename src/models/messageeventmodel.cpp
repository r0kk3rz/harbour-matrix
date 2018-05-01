#include "messageeventmodel.h"

#include <algorithm>
#include <QtCore/QRegularExpression>
#include <QtCore/QDebug>

#include "connection.h"
#include "room.h"
#include "user.h"
#include "events/event.h"
#include "events/roommessageevent.h"
#include "events/roommemberevent.h"
#include "events/simplestateevents.h"
#include "events/redactionevent.h"

MessageEventModel::MessageEventModel(QObject* parent)
    : QAbstractListModel(parent)
{
    m_currentRoom = 0;
    m_connection = 0;
}

MessageEventModel::~MessageEventModel()
{
}

void MessageEventModel::changeRoom(QString roomId)
{
    QMatrixClient::Room * room = m_connection->roomMap().value(qMakePair(roomId, false));
    qDebug() << "changing to room " << room->name();
    changeRoom(room);
}

void MessageEventModel::changeRoom(QMatrixClient::Room* room)
{
    if (room == m_currentRoom)
        return;

    beginResetModel();
    if( m_currentRoom )
    {
        m_currentRoom->disconnect(this);
    }
    m_currentRoom = room;
    if( room )
    {
        using namespace QMatrixClient;
        connect(m_currentRoom, &Room::aboutToAddNewMessages, this,
                [=](RoomEventsRange events)
                {
                    beginInsertRows(QModelIndex(), 0, int(events.size()) - 1);
                });
        connect(m_currentRoom, &Room::aboutToAddHistoricalMessages, this,
                [=](RoomEventsRange events)
                {
                    beginInsertRows(QModelIndex(), rowCount(),
                                    rowCount() + int(events.size()) - 1);
                });
        connect(m_currentRoom, &Room::readMarkerMoved, this, [this] {
            refreshEventRoles(
                std::exchange(lastReadEventId,
                              m_currentRoom->readMarkerEventId()),
                {ReadMarkerRole});
            refreshEventRoles(lastReadEventId, {ReadMarkerRole});
        });
        connect(m_currentRoom, &Room::replacedEvent, this,
                [this] (const RoomEvent* newEvent) {
                    refreshEvent(newEvent->id());
        });
        connect(m_currentRoom, &Room::addedMessages,
                this, &MessageEventModel::endInsertRows);

        connect(m_currentRoom, &Room::fileTransferProgress,
                this, &MessageEventModel::refreshEvent);
        connect(m_currentRoom, &Room::fileTransferCompleted,
                this, &MessageEventModel::refreshEvent);
        connect(m_currentRoom, &Room::fileTransferFailed,
                this, &MessageEventModel::refreshEvent);
        connect(m_currentRoom, &Room::fileTransferCancelled,
                this, &MessageEventModel::refreshEvent);
        qDebug() << "Connected to room" << room->id()
            << "as" << room->connection()->userId();
    }

    lastReadEventId = room ? room->readMarkerEventId() : "";

    endResetModel();
}

QMatrixClient::Room * MessageEventModel::getRoom()
{
    return m_currentRoom;
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

void MessageEventModel::refreshEvent(const QString& eventId)
{
    refreshEventRoles(eventId, {});
}

void MessageEventModel::refreshEventRoles(const QString& eventId,
                                     const QVector<int> roles)
{
    const auto it = m_currentRoom->findInTimeline(eventId);
    if (it != m_currentRoom->timelineEdge())
    {
        const auto row = it - m_currentRoom->messageEvents().rbegin();
        emit dataChanged(index(row), index(row), roles);
    }
}

QVariant MessageEventModel::data(const QModelIndex& index, int role) const
{
    using namespace QMatrixClient;

    if( !m_currentRoom ||
            index.row() < 0 || index.row() >= m_currentRoom->messageEvents().size() )
        return QVariant();

    const RoomEvent *event = (m_currentRoom->messageEvents().rbegin() + index.row())->event();

    if( role == Qt::DisplayRole )
    {
        if (event->isRedacted())
        {
            auto reason = event->redactedBecause()->reason();
            if (reason.isEmpty())
                return tr("Redacted");
            else
                return tr("Redacted: %1")
                    .arg(event->redactedBecause()->reason());
        }

        if( event->type() == EventType::RoomMessage )
        {
            const RoomMessageEvent* e = static_cast<const RoomMessageEvent*>(event);
            User* user = m_connection->user(e->senderId());
            return QString("%1 (%2): %3").arg(user->displayname()).arg(user->id()).arg(e->plainBody());
        }
        if( event->type() == EventType::RoomMember )
        {
            const RoomMemberEvent* e = static_cast<const RoomMemberEvent*>(event);

            QString subjectName = m_currentRoom->roomMembername(e->userId());

            switch( e->membership() )
            {
                case MembershipType::Join:
                    return QString("%1 (%2) joined the room").arg(e->displayName(), subjectName);
                case MembershipType::Leave:
                    return QString("%1 (%2) left the room").arg(e->displayName(), subjectName);
                case MembershipType::Ban:
                    return QString("%1 (%2) was banned from the room").arg(e->displayName(), subjectName);
                case MembershipType::Invite:
                    return QString("%1 (%2) was invited to the room").arg(e->displayName(), subjectName);
                case MembershipType::Knock:
                    return QString("%1 (%2) knocked").arg(e->displayName(), subjectName);
                case MembershipType::Undefined:
                    return QString("Undefined");
            }
        }
        if( event->type() == EventType::RoomAliases )
        {
            auto* e = static_cast<const RoomAliasesEvent*>(event);
            return tr("set aliases to: %1").arg(e->aliases().join(", "));
        }
        if( event->type() == EventType::RoomCanonicalAlias )
        {
            auto* e = static_cast<const RoomCanonicalAliasEvent*>(event);
            if (e->alias().isEmpty())
                return tr("cleared the room main alias");
            else
                return tr("set the room main alias to: %1").arg(e->alias());
        }
        if( event->type() == EventType::RoomName )
        {
            auto* e = static_cast<const RoomNameEvent*>(event);
            if (e->name().isEmpty())
                return tr("cleared the room name");
            else
                return tr("set the room name to: %1").arg(e->name());
        }
        if( event->type() == EventType::RoomTopic )
        {
            auto* e = static_cast<const RoomTopicEvent*>(event);
            if (e->topic().isEmpty())
                return tr("cleared the topic");
            else
                return tr("set the topic to: %1").arg(e->topic());
        }
        if( event->type() == EventType::RoomAvatar )
        {
            return tr("changed the room avatar");
        }
        if( event->type() == EventType::RoomEncryption )
        {
            return tr("activated End-to-End Encryption");
        }
        return "Unknown Event";
    }

    if( role == Qt::ToolTipRole )
    {
        return event->originalJson();
    }

    if( role == EventTypeRole )
    {
        if( event->type() == EventType::RoomMessage )
        {
            //  Text, Emote, Notice, Image, File, Location, Video, Audio, Unknown

            switch (static_cast<const RoomMessageEvent*>(event)->msgtype())
            {
                case MessageEventType::Emote:
                    return "emote";
                case MessageEventType::Notice:
                    return "notice";
                case MessageEventType::Image:
                    return "image";
                case MessageEventType::File:
                    return "file";
                case MessageEventType::Audio:
                case MessageEventType::Video:
                    return "media";
                case MessageEventType::Unknown:
                    return "unknown";
            default:
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
            const RoomMessageEvent* e = static_cast<const RoomMessageEvent*>(event);
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
                static_cast<const RoomMessageEvent*>(event)->mimeType().name();
            return contentType == "text/plain" ? "text/html" : contentType;
        }
        return "text/plain";
    }

    if( role == ContentRole )
    {
        if (event->isRedacted())
         {
             auto reason = event->redactedBecause()->reason();
             if (reason.isEmpty())
                 return tr("Redacted");
             else
                 return tr("Redacted: %1")
                     .arg(event->redactedBecause()->reason());
         }

        if( event->type() == EventType::RoomMessage )
        {
            using namespace MessageEventContent;

            auto e = static_cast<const RoomMessageEvent*>(event);
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
            case MessageEventType::File:
            case MessageEventType::Audio:
            case MessageEventType::Video:
            default:
                return e->plainBody();
            }
        }
        if( event->type() == EventType::RoomMember )
        {
            auto e = static_cast<const RoomMemberEvent*>(event);
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
            const RoomAliasesEvent* e = static_cast<const RoomAliasesEvent*>(event);
            return QString("Current aliases: %1").arg(e->aliases().join(", "));
        }
        if( event->type() == EventType::RoomAliases )
        {
            auto e = static_cast<const RoomAliasesEvent*>(event);
            return tr("set aliases to: %1").arg(e->aliases().join(", "));
        }
        if( event->type() == EventType::RoomCanonicalAlias )
        {
            auto e = static_cast<const RoomCanonicalAliasEvent*>(event);
            return tr("set the room main alias to: %1").arg(e->alias());
        }
        if( event->type() == EventType::RoomName )
        {
            auto e = static_cast<const RoomNameEvent*>(event);
            return tr("set the room name to: %1").arg(e->name());
        }
        if( event->type() == EventType::RoomTopic )
        {
            auto e = static_cast<const RoomTopicEvent*>(event);
            return tr("set the topic to: %1").arg(e->topic());
        }
        if( event->type() == EventType::RoomEncryption )
        {
            auto e = static_cast<const EncryptionEvent*>(event);
            return tr("activated End-to-End Encryption (algorithm: %1)")
                .arg(e->algorithm());
        }
        return "Unknown Event";
    }

    if( role == HighlightRole )
    {
        if( event->type() == EventType::RoomMessage )
        {
            const RoomMessageEvent* message = static_cast<const RoomMessageEvent*>(event);
            User* localUser = m_currentRoom->connection()->user();

            bool m_isHighlight = message->senderId() != localUser->id() &&
                (message->plainBody().contains(localUser->id()) ||
                 message->plainBody().contains(localUser->displayname()));

            return m_isHighlight;
        }
    }

    if( role == ReadMarkerRole )
    {
        return event->id() == lastReadEventId;
    }

    if( role == SpecialMarksRole )
    {
        if (event->isStateEvent() &&
                static_cast<const StateEventBase*>(event)->repeatsState())
            return "hidden";
        return event->isRedacted() ? "redacted" : "";
    }

    if( role == LongOperationRole )
    {
        if (event->type() == EventType::RoomMessage &&
                static_cast<const RoomMessageEvent*>(event)->hasFileContent())
        {
            auto info = m_currentRoom->fileTransferInfo(event->id());
            return QVariant::fromValue(info);
        }
    }

    if(role == AvatarRole)
    {
        User *user = m_connection->user(event->senderId());
        if(user->avatarUrl().isValid())
        {
            return QUrl("image://mxc/" + user->avatarUrl().host() + user->avatarUrl().path());
        }
            return QUrl();
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
