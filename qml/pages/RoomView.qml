import QtQuick 2.2
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Matrix 1.0
import "../components/custom"

Page {
    id: room

    function setRoom(roomid) {
        chat.setRoom(roomid)
    }

    function setConnection(conn) {
        chat.setConnection(conn)
    }

    function sendLine(line) {
        chat.sendLine(line)
        textArea.text = ''
    }
    Rectangle {
        color: "Black"
        anchors.fill: parent
        visible: useBlackBackground
        opacity: 0.8
    }

    property string displayText: currentRoom ? currentRoom.name : ""
    property string extraText: currentRoom ? currentRoom.topic : ""
    property string imageSource: currentRoom ? ("image://mxc/" + String(
                                                    currentRoom.avatarUrl).substring(
                                                    6)) : ""

    property Connection currentConnection: null
    property var currentRoom: null

    onStatusChanged: {
        if (status == PageStatus.Active
                && pageStack._currentContainer.attachedContainer === null) {
            pageStack.pushAttached(Qt.resolvedUrl("../pages/DetailsPage.qml"), {
                                       "currentRoom": currentRoom
                                   })
        }
    }

    Item {
        id: bubbleItem
        width: Theme.iconSizeLauncher
        height: width
        anchors.top: parent.top
        anchors.margins: Theme.horizontalPageMargin
        anchors.right: parent.right
        AvatarBubble {
            id: bubble

            height: parent.height

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            imageVisible: imageSource
            imageSource: room.imageSource

            rectLabelVisible: !imageVisible
            rectColor: imageVisible ? Theme.secondaryColor : stringToColour(
                                          displayText)
            rectLabelText: displayText.charAt(0).toUpperCase()
        }
    }

    PageHeader {
        anchors.top: parent.top
        id: pageHeader
        anchors.left: parent.left
        anchors.right: bubbleItem.left
        title: displayText
        description: extraText
    }

    SilicaFlickable {
        id: flickable
        clip: true
        anchors.fill: parent
        anchors.topMargin: pageHeader.height
        contentHeight: col.height

        ColumnLayout {
            id: col
            width: parent.width
            height: room.height - pageHeader.height

            ChatRoom2 {
                width: parent.width
                clip: true
                id: chat
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                model: messageModel
                onHeightChanged: {
                    if ((height <= Screen.height / 2)) {
                        if (wantToScroll) {
                            listView.positionViewAtEnd()
                        }
                    }
                }
            }
            Item {
                anchors.bottom: parent.bottom

                id: footer
                z: 3
                width: parent.width
                height: textArea.height
                Layout.fillWidth: true
                Layout.minimumHeight: textArea.height

                Label {
                    id: typingLabel
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    anchors.bottom: textArea.top
                }

                Item {
                    anchors.fill: parent
                    TextArea {
                        id: textArea
                        anchors.left: parent.left
                        anchors.right: sendIcon.left
                        anchors.rightMargin: Theme.paddingSmall
                        //focus: true
                        height: Math.min(room.height / 2, implicitHeight)
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -Theme.paddingMedium
                        placeholderText: qsTr("Message @")
                                         + (currentRoom ? currentRoom.displayName : "")
                        focusOutBehavior: FocusBehavior.KeepFocus
                        onFocusChanged: {
                            if (focus) {
                                if (listView.atYEnd) {
                                    listView.wantToScroll = true
                                }
                            } else {
                                listView.wantToScroll = false
                            }
                        }
                    }
                    InverseMouseArea {
                        anchors.fill: parent
                        onClickedOutside: {
                            textArea.focus = false
                        }
                    }

                    IconCustomButton {
                        margins: Theme.paddingLarge
                        enabled: textArea.text.length > 0
                        id: sendIcon
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        width: height
                        height: Theme.itemSizeMedium
                        source: "qrc:/res/send.svg"
                        onClicked: {
                            sendLine(textArea.text)
                            textArea.text = ""
                        }
                    }
                }
            }

            PushUpMenu {
                id: pushUpMenu
                MenuItem {
                    text: qsTr("Add attachment")
                    enabled: false
                }
                MenuItem {
                    text: qsTr("Add photo")
                    enabled: false
                }
            }
        }
    }

    MessageEventModel {
        id: messageModel
    }

    Component.onCompleted: {
        setConnection(connection)
    }
}
