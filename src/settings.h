#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QSettings>

class Settings : public QSettings
{
    Q_OBJECT
public:
    Settings(QObject *parent = NULL);
    virtual ~Settings();

    Q_INVOKABLE void setValue(const QString &key, const QVariant &value);
    Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;
    Q_INVOKABLE bool contains(const QString &key) const;
    Q_INVOKABLE bool getSetting(const QString &key) const;
    Q_INVOKABLE void sync();
};

#endif // SETTINGS_H
