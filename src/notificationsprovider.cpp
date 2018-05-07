#include "notificationsprovider.h"
#include "connection.h"
#include "events/roommessageevent.h"
#include "csapi/notifications.h"
#include <QCoreApplication>
#include <backgroundactivity.h>
#include <notification.h>
#include "user.h"
#include "events/event.h"

  NotificationsProvider::NotificationsProvider(QMatrixClient::Connection *connection): QObject()
  {
    m_connection = connection;

    m_activity = new BackgroundActivity(this);
    connect(m_activity, SIGNAL(running()), this, SLOT(startRun()));
    m_activity->wait(BackgroundActivity::ThirtySeconds);
  }

  void NotificationsProvider::startRun()
  {
    using namespace QMatrixClient;

    const QString from("");
    int limit = 10;
    const QString filter("");
    auto notificationjob = m_connection->callApi<GetNotificationsJob>(from, limit, filter);

    connect( notificationjob, &GetNotificationsJob::success, this, &NotificationsProvider::processNotifications);

    m_activity->wait();
  }

  void NotificationsProvider::processNotifications(QMatrixClient::BaseJob *job)
  {
      using namespace QMatrixClient;

      auto notificationjob = static_cast<GetNotificationsJob*>(job);

      for(auto&& notification : notificationjob->notifications())
      {
          if(notification.read == false)
          {
              if( notification.event->type() == EventType::RoomMessage )
              {
                  auto e = ptrCast<RoomMessageEvent>(move(notification.event));
                  User *user = m_connection->user(e->senderId());

                  sendSailfishNotification(notification.roomId, user->displayname(), e->plainBody(), e->id(), QDateTime::fromMSecsSinceEpoch(notification.ts));
              }
          }
          else
          {
              // Figure out if we need to close any notifications
          }
      }
  }

  void NotificationsProvider::sendSailfishNotification(QString roomid, QString sender, QString message, QString origin, QDateTime timestamp)
  {
      Notification* notification = nullptr;

      for(auto existing : Notification::notifications())
      {
          Notification* existingNotification = static_cast<Notification*>(existing);

          if(existingNotification->origin() == origin)
          {
              if(existingNotification->previewBody() != message)
              {
                  notification = existingNotification;
                  break;
              }
              else
              {
                  return;
              }
          }
      }

        if(notification == nullptr)
        {
            notification = new Notification(this);
        }

         QVariantMap remoteaction;
         remoteaction["name"] = "default";
         remoteaction["service"] = "org.harbour.matrix";
         remoteaction["path"] = "/";
         remoteaction["iface"] = "org.harbour.matrix";
         remoteaction["method"] = "openRoom";
         remoteaction["arguments"] = (QVariantList() << roomid);
         remoteaction["icon"] = "icon-m-notifications";

         notification->setRemoteAction(remoteaction);


         notification->setCategory("harbour.matrix.notification");
         notification->setAppName("harbour-matrix");
         notification->setTimestamp(timestamp);
         notification->setOrigin(origin);

         notification->setPreviewSummary(sender);
         notification->setSummary(sender);

         notification->setPreviewBody(message);
         notification->setBody(message);

         notification->publish();
  }



