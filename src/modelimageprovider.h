#ifndef MODELIMAGEPROVIDER_H
#define MODELIMAGEPROVIDER_H


#include <QQuickImageProvider>

namespace QMatrixClient
{
    class Room;
}

class ModelImageProvider : public QQuickImageProvider
{
public:
    ModelImageProvider();

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) Q_DECL_OVERRIDE;

private:
    static const QSize THUMBNAIL_SIZE;

    const QString _thumbnailsdir;
};

#endif // MODELIMAGEPROVIDER_H
