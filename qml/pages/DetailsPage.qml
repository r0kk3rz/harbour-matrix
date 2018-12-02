import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components/custom"

Page {
    id: root

    property string displayText: currentRoom ? currentRoom.name : connection.localUser.displayName
    property string extraText: currentRoom ? currentRoom.topic : connection.localUser.fullName
    property string imageSource: currentRoom ? ("image://mxc/" + String(
                                                    currentRoom.avatarUrl).substring(
                                                    6)) : ("image://mxc/" + String(
                                                               connection.localUser.avatarUrl).substring(
                                                               6))

    property var currentRoom: null

    canNavigateForward: true

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            if (doOnce) {

                pageStack.completeAnimation()
                pageStack.pushAttached(Qt.resolvedUrl("../pages/RoomsPage.qml"))
                pageStack.navigateForward(PageStackAction.Immediate)
                doOnce = false
            }
        }
    }

    property bool doOnce: true

    Column {
        id: content
        width: parent.width
        spacing: Theme.paddingLarge

        PageHeader {
            id: pageheader
            title: qsTr("Details")
        }

        Image {
            id: sglogo
            anchors.horizontalCenter: parent.horizontalCenter
            source: imageSource
        }

        Column {
            anchors {
                left: parent.left
                right: parent.right
            }

            Label {
                id: sgswname
                anchors {
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.pixelSize: Theme.fontSizeLarge
                text: displayText
            }

            Label {
                visible: false
                id: sgversion
                anchors {
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: {
                    window.appName + " v" + window.version
                }
            }

            Label {
                id: sginfo
                anchors {
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: extraText
            }

            Label {
                visible: false
                anchors {
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                text: qsTr("harbour-matrix is an unofficial Matrix Client for SailfishOS and distributed under the GPLv3 license.")
            }
        }

        Column {
            visible: false
            anchors {
                left: parent.left
                right: parent.right
                topMargin: Theme.paddingExtraLarge
            }
            spacing: Theme.paddingSmall

            Button {
                id: developersbutton
                text: qsTr("Developers")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: pageStack.push(Qt.resolvedUrl("DevelopersPage.qml"))
            }

            Button {
                id: translationsbutton
                text: qsTr("Translations")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: pageStack.push(Qt.resolvedUrl(
                                              "TranslationsPage.qml"), {
                                              "context": root.context
                                          })
            }
        }
    }
}
