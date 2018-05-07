#ifndef NOTIFICATIONSPROVIDER_H
#define NOTIFICATIONSPROVIDER_H

#include "connection.h"
#include "csapi/notifications.h"
#include <backgroundactivity.h>

class NotificationsProvider : public QObject
{
    Q_OBJECT
public:
    NotificationsProvider(QMatrixClient::Connection* connection);

public slots:
    void startRun();
    void processNotifications(QMatrixClient::BaseJob *job);
    void sendSailfishNotification(QString id, QString sender, QString message, QString origin, QDateTime timestamp);

private:
    QMatrixClient::Connection* m_connection;
    BackgroundActivity* m_activity;
};

#endif // NOTIFICATIONSPROVIDER_H
