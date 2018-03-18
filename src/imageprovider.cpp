#include "imageprovider.h"

#include "lib/connection.h"
#include "jobs/mediathumbnailjob.h"

#include <QtCore/QDebug>
#include <QtCore/QStandardPaths>
#include <QtCore/QFile>
#include <QtCore/QFileInfo>
#include <QtCore/QDir>

ImageProvider::ImageProvider(QMatrixClient::Connection* connection)
    : QQuickImageProvider(QQmlImageProviderBase::Image, QQmlImageProviderBase::ForceAsynchronousImageLoading),
      m_connection(connection)
{
    qRegisterMetaType<QImage*>();
    qRegisterMetaType<QWaitCondition*>();

    cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
}

QImage ImageProvider::requestImage(const QString& id,
                                     QSize* size, const QSize& requestedSize)
{
    QImage result;

    if(id == "")
    {
        return result;
    }

    QWaitCondition condition;

    QMetaObject::invokeMethod(this, "doRequest", Qt::QueuedConnection,
                              Q_ARG(QString, "mxc://" + id), Q_ARG(QSize, requestedSize),
                              Q_ARG(QImage*, &result),
                              Q_ARG(QWaitCondition*, &condition));
    condition.wait(&m_mutex);

    if( size != nullptr )
    {
        *size = result.size();
    }

    return result;
}

void ImageProvider::setConnection(const QMatrixClient::Connection* connection)
{
    m_connection = connection;
}

void ImageProvider::doRequest(QString id, QSize requestedSize, QImage* pixmap,
                              QWaitCondition* condition)
{
    Q_ASSERT(pixmap);
    Q_ASSERT(condition);

    QFileInfo fileinfo {
        cachePath + "/" + id + "-" + QString("%1x%2").arg(requestedSize.height()).arg(requestedSize.width()) + ".png"
    };

    if (!fileinfo.dir().exists())
        fileinfo.dir().mkpath(".");

    QFile *file = new QFile(fileinfo.absoluteFilePath());

    if(file->exists())
    {
        *pixmap = QImage();
        pixmap->load(file, "PNG");
        condition->wakeAll();
        return;
    }

    if( !m_connection )
    {
        qDebug() << "ImageProvider::requestPixmap: no connection!";
        *pixmap = QImage();
        condition->wakeAll();
        return;
    }

    using QMatrixClient::MediaThumbnailJob;
    auto job = m_connection->callApi<MediaThumbnailJob>(QUrl(id), requestedSize);

    connect( job, &MediaThumbnailJob::finished, this, [=]()
    {
        // TODO: need to check result to see if this is success or not
        // No need to lock because we don't deal with the ImageProvider state
        *pixmap = job->thumbnail();
        pixmap->save(file, "PNG");
        condition->wakeAll();
    } );
}

