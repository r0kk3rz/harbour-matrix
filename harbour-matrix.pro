# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-matrix

CONFIG += c++11 sailfishapp

include(lib/libqmatrixclient.pri)

SOURCES += src/harbour-matrix.cpp \
    src/settings.cpp \
    src/models/messageeventmodel.cpp \
    src/models/roomlistmodel.cpp

OTHER_FILES += qml/harbour-matrix.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-matrix.changes.in \
    rpm/harbour-matrix.spec \
    rpm/harbour-matrix.yaml \
    translations/*.ts \
    harbour-matrix.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-matrix-de.ts

HEADERS += \
    src/settings.h \
    src/models/messageeventmodel.h \
    src/models/roomlistmodel.h

DISTFILES += \
    qml/pages/Login.qml \
    qml/pages/RoomsPage.qml \
    qml/pages/RoomView.qml \
    qml/pages/ChatRoom.qml \
    qml/pages/ChatRoom2.qml \
    qml/pages/SettingsPage.qml
