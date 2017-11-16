TARGET = harbour-matrix

i18n_files.files = translations
i18n_files.path = /usr/share/$$TARGET

INSTALLS += i18n_files

CONFIG += c++11 sailfishapp

include(lib/libqmatrixclient.pri)

SOURCES += src/harbour-matrix.cpp \
    src/models/messageeventmodel.cpp \
    src/models/roomlistmodel.cpp \
    src/imageprovider.cpp

OTHER_FILES += qml/harbour-matrix.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-matrix.changes.in \
    rpm/harbour-matrix.spec \
    rpm/harbour-matrix.yaml \
    translations/*.ts \
    harbour-matrix.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

CONFIG += sailfishapp_i18n

TRANSLATIONS += translations/harbour-matrix.ts \
                translations/harbour-matrix.es.ts 

HEADERS += \
    src/models/messageeventmodel.h \
    src/models/roomlistmodel.h \
    src/imageprovider.h

DISTFILES += \
    qml/components/about/CollaboratorsLabel.qml \
    qml/components/about/ThirdPartyLabel.qml \
    qml/components/custom/BackgroundRectangle.qml \    
    qml/components/custom/ClickableLabel.qml \
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
