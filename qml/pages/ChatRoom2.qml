import QtQuick 2.2
import Sailfish.Silica 1.0
import Matrix 1.0
import "../components/custom"
import "../components"

SilicaListView {
    id: chatView
    anchors.fill: parent
    flickableDirection: Flickable.VerticalFlick
    verticalLayoutDirection: ListView.BottomToTop
    model: MessageEventModel {
        id: messageModel
    }
    clip: true
    property Connection currentConnection: null
    property var currentRoom: null
    property string textvalue: ""

    function setRoom(roomIndex) {
        messageModel.changeRoom(roomIndex)
        currentRoom = messageModel.getRoom()

        currentRoom.getPreviousContent()
        currentRoom.markAllMessagesAsRead()
        currentRoom.resetHighlightCount()

        currentRoom.typingChanged.connect(onTypingChanged)
    }

    function setConnection(conn) {
        currentConnection = conn
        messageModel.setConnection(conn)
    }

    function sendLine(text) {
        if (!currentRoom || !currentConnection)
            return
        currentConnection.postMessage(currentRoom, "m.text", text)
    }

    function onModelReset() {
        if (currentRoom) {
            currentRoom.getPreviousContent(25)
        }
    }

    function onTypingChanged() {
        var typing = currentRoom.usersTyping()
        var text = ""

        console.log("typing changed...")

        if (typing.length > 0) {
            for (var i = 0, len = typing.length; i < len; i++) {
                text = text + currentRoom.roomMembername(typing[i]) + ", "
            }
            text = text + "typing..."
        }

        typingLabel.text = text
    }

    header: Column {

        Label {
            id: typingLabel
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
        }

        TextArea {
            id: textEntry
            width: chatView.width
            placeholderText: qsTr("Message @") + (currentRoom ? currentRoom.displayName : "")
            EnterKey.onClicked: {
                sendLine(text)
                textEntry.text = ""
            }
        }
    }

    delegate: Item {
        id: myListItem
        width: chatView.width
        height: visible ? labelColumn.height + Theme.paddingSmall : 0

        ListView.onAdd: AddAnimation {
            target: myListItem
            duration: 300
        }

        Component.onCompleted: {
            if (eventType == "message") {
                var component = Qt.createComponent(
                            Qt.resolvedUrl("../components/TextMessageItem.qml"))
                component.createObject(labelColumn, {
                                           itemText: content
                                       })
            } else if (eventType == "image") {
                var component = Qt.createComponent(
                            Qt.resolvedUrl(
                                "../components/MediaMessageItem.qml"))
                component.createObject(labelColumn, {
                                           itemContent: content,
                                           type: eventType
                                       })
            } else {
                var component = Qt.createComponent(
                            Qt.resolvedUrl(
                                "../components/StatusMessageItem.qml"))
                component.createObject(labelColumn, {
                                           itemText: content
                                       })
            }
        }

        Column {
            id: labelColumn
            x: Theme.paddingMedium
            width: parent.width - x - x

            Item {
                id: messageItem
                height: eventType == "message" ? authorLabel.height
                                                 + Theme.paddingLarge : authorLabel.height
                                                 + Theme.paddingLarge
                visible: eventType == "message" ? (myListItem.ListView.nextSection
                                                   != myListItem.ListView.section) : false
                width: parent.width
                Rectangle {
                    id: bubble
                    height: Theme.paddingLarge + Theme.paddingMedium
                    width: height
                    radius: height / 2
                    anchors.bottom: parent.bottom
                    color: userAvatar.visible == false ? useFancyColors ? stringToColour(author) : Theme.secondaryHighlightColor : "white"
                    Label {
                        anchors.centerIn: parent
                        text: eventType == "message" ? author.charAt(
                                                           0).toUpperCase() : ""
                        font.pixelSize: parent.height * 0.8
                        visible: userAvatar.visible == false
                    }

                    AvatarImage {
                        id: userAvatar
                        iconSource: avatar
                        iconSize: parent.height
                        visible: avatar != ""
                    }
                }

                Label {
                    id: authorLabel
                    text: eventType == "message" ? author : ""
                    anchors.left: bubble.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.verticalCenter: bubble.verticalCenter
                    color: eventType == "message" ? useFancyColors ? stringToColour(
                                                                         author) : Theme.secondaryHighlightColor : ""
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }
                Label {
                    id: timeLabel
                    text: eventType == "message" ? time.toLocaleTimeString(
                                                       "hh:mm:ss") : ""
                    anchors.right: parent.right
                    anchors.verticalCenter: bubble.verticalCenter
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor
                }
            }
        }
    }

    VerticalScrollDecorator {
        flickable: chatView
    }

    section {
        property: "author"
    }

    Connections {
        target: messageModel
        onModelReset: onModelReset()
    }

    onAtYBeginningChanged: {
        if (currentRoom && atYBeginning)
            currentRoom.getPreviousContent()
    }
}
