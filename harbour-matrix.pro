TARGET = harbour-matrix

i18n_files.files = translations
i18n_files.path = /usr/share/$$TARGET

INSTALLS += i18n_files

lipstick_config.files = $$PWD/*.conf
lipstick_config.path  = /usr/share/lipstick/notificationcategories
INSTALLS    += lipstick_config

CONFIG += c++14 sailfishapp

PKGCONFIG += keepalive
PKGCONFIG += nemonotifications-qt5

QMAKE_CXX=/opt/gcc6/bin/g++
QMAKE_CC=/opt/gcc6/bin/gcc
QMAKE_LINK=/opt/gcc6/bin/g++

include(lib/libqmatrixclient.pri)

LIBS += -lz -L/opt/gcc6/lib \
            -Lkeepalive \
            -Lnemonotifications-qt5 \
            -Lnemodbus \
            -static-libstdc++

SOURCES += src/harbour-matrix.cpp \
    src/models/messageeventmodel.cpp \
    src/models/roomlistmodel.cpp \
    src/scriptlauncher.cpp \
    src/imageprovider.cpp \
    src/notificationsprovider.cpp

OTHER_FILES += qml/harbour-matrix.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-matrix.changes.in \
    rpm/harbour-matrix.spec \
    translations/*.ts \
    harbour-matrix.desktop \
    harbour.matrix.notification.conf

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

CONFIG += sailfishapp_i18n

TRANSLATIONS += translations/harbour-matrix.ts \
                translations/harbour-matrix-es.ts \
                translations/harbour-matrix-de.ts

HEADERS += \
    src/models/messageeventmodel.h \
    src/models/roomlistmodel.h \
    src/scriptlauncher.h \
    src/imageprovider.h \
    src/notificationsprovider.h

DISTFILES += \
    qml/components/about/CollaboratorsLabel.qml \
    qml/components/about/ThirdPartyLabel.qml \
    qml/components/custom/BackgroundRectangle.qml \    
    qml/components/custom/ClickableLabel.qml \
    qml/components/custom/AvatarImage.qml \
    qml/components/textlabel/TextLabel.qml \
    qml/components/translation/IconTextButton.qml \
    qml/pages/ThirdPartyPage.qml \
    qml/pages/DevelopersPage.qml \
    qml/pages/TranslationsPage.qml \
    qml/pages/AboutPage.qml \    
    qml/pages/Login.qml \
    qml/pages/RoomsPage.qml \
    qml/pages/RoomView.qml \
    qml/pages/ChatRoom.qml \
    qml/pages/ChatRoom2.qml \
    qml/pages/SettingsPage.qml

RESOURCES += \
    resources.qrc
