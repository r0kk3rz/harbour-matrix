#include "settings.h"

Settings::Settings(QObject *parent)
    : QSettings(parent) {
}

Settings::~Settings() {
}

void Settings::setValue(const QString &key, const QVariant &value) {
    QSettings::setValue(key, value);
}

QVariant Settings::value(const QString &key, const QVariant &defaultValue) const {
    return QSettings::value(key, defaultValue);
}

bool Settings::contains(const QString &key) const {
    return QSettings::contains(key);
}

bool Settings::getSetting(const QString &key) const {
    return QSettings::value(key).toBool();
}

void Settings::sync() {
    QSettings::sync();
}
