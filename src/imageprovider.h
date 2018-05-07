#pragma once

#include <QtQuick/QQuickImageProvider>
#include <QtCore/QMutex>
#include <QtCore/QWaitCondition>

namespace QMatrixClient {
    class Connection;
}

class ImageProvider: public QObject, public QQuickImageProvider
{
        Q_OBJECT
    public:
        explicit ImageProvider(QMatrixClient::Connection* connection);

        QImage requestImage(const QString& id, QSize* size,
                              const QSize& requestedSize) override;

        Q_INVOKABLE void setConnection(const QMatrixClient::Connection* connection);

    private:
        Q_INVOKABLE void doRequest(QString id, QSize requestedSize,
                                   QImage* pixmap, QWaitCondition* condition);

        const QMatrixClient::Connection* m_connection;
        QString cachePath;
        QMutex m_mutex;
};

Q_DECLARE_METATYPE(QImage*)
Q_DECLARE_METATYPE(QWaitCondition*)
