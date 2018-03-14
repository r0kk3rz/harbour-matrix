import QtQuick 2.2
import Sailfish.Silica 1.0
import Matrix 1.0
import "../components/custom"

SilicaListView {
        id: chatView
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        verticalLayoutDirection: ListView.BottomToTop
        model: MessageEventModel { id: messageModel }
        clip:true
        property Connection currentConnection: null
        property var currentRoom: null
        property string textvalue: ""

        function setRoom(room) {
            currentRoom = room
            messageModel.changeRoom(room)
            room.markAllMessagesAsRead()
            room.resetHighlightCount()
        }

        function setConnection(conn) {
            currentConnection = conn
            messageModel.setConnection(conn)
        }

        function sendLine(text) {
            if(!currentRoom || !currentConnection) return
            currentConnection.postMessage(currentRoom, "m.text", text)
        }

        function stringToColour(str) {
          var hash = 0;
          for (var i = 0; i < str.length; i++) {
            hash = str.charCodeAt(i) + ((hash << 5) - hash);
          }
          var colour = '#';
          for (var i = 0; i < 3; i++) {
            var value = (hash >> (i * 8)) & 0xFF;
            colour += ('00' + value.toString(16)).substr(-2);
          }
          return colour;
        }

        header: TextArea {
            id: textEntry
            width: chatView.width
            placeholderText: qsTr("Message @") + currentRoom.displayName
            EnterKey.onClicked: {
                sendLine(text)
                textEntry.text = ""
            }
        }

        delegate: ListItem {
            id: myListItem
            menu: contextMenuComponent
            width: chatView.width
            contentHeight: visible ? labelColumn.height+ Theme.paddingSmall : 0

            ListView.onAdd: AddAnimation {
                target: myListItem
                duration: 300
            }

            Column {
                id: labelColumn
                x: Theme.paddingMedium
                width: parent.width - x-x

                Item {
                    height: eventType == "message" ? authorLabel.height+ Theme.paddingLarge: authorLabel.height+  Theme.paddingLarge
                    visible: eventType == "message" ? (myListItem.ListView.nextSection != myListItem.ListView.section) : false
                    width: parent.width
                    Rectangle {
                        id: bubble
                        height: Theme.paddingLarge + Theme.paddingMedium
                        width: height
                        radius: height/2
                        anchors.bottom: parent.bottom
                        color: eventType == "message" ? useFancyColors ? stringToColour(author): Theme.secondaryHighlightColor: ""
                        Label {
                            anchors.centerIn: parent
                            text:  eventType == "message" ? author.charAt(0).toUpperCase() : ""
                            font.pixelSize: parent.height *0.8
                        }
                    }

                    AvatarImage {
                        id: userAvatar
                        iconSource: avatar
                        iconSize: Theme.paddingLarge + Theme.paddingMedium
                        anchors.bottom: parent.bottom
                        visible: avatar == Image.Null ? false : true
                    }

                    Label {
                        id: authorLabel
                        text: eventType == "message" ? author : ""
                        anchors.left: bubble.right
                        anchors.leftMargin: Theme.paddingMedium
                        anchors.verticalCenter: bubble.verticalCenter
                        color: eventType == "message" ? useFancyColors ? stringToColour(author) : Theme.secondaryHighlightColor: ""
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                    }
                    Label {
                        id: timeLabel
                        text: eventType == "message" ? time.toLocaleTimeString("hh:mm:ss") : ""
                        anchors.right: parent.right
                        anchors.verticalCenter: bubble.verticalCenter
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.secondaryColor
                    }
                }

                Label {
                    x: parent.x + Theme.paddingLarge + Theme.paddingMedium
                    width: parent.width - x
                    height: eventType == "message" ? undefined:  lineCount* font.pixelSize + Theme.paddingMedium
                    id: chattext
                    text:content
                    verticalAlignment: Text.AlignBottom
                    horizontalAlignment: eventType == "message" ? Text.AlignLeft : Text.AlignHCenter
                    color: eventType == "message" ? Theme.primaryColor: Theme.secondaryColor
                    wrapMode: Text.WordWrap
                    font.pixelSize: eventType == "message" ? Theme.fontSizeSmall : Theme.fontSizeTiny
                }
            }

            Component {
                id: contextMenuComponent
                ContextMenu {
                    TextArea {
                        x: 10
                        width: chatView.width -x
                        text: content
                        color: Theme.highlightColor
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeExtraSmall
                        Component.onCompleted: selectAll();
                    }

                }
            }

        }

        VerticalScrollDecorator {
            flickable: chatView
        }

        section {
            property: "author"
            //criteria: ViewSection.FullString
            //labelPositioning: ViewSection.InlineLabels
            /*delegate:
                Label {
                    width: parent.width
                    //text: chatView.ListView.nextSection //section.toLocaleString(Qt.locale())
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }*/


        }

        onAtYBeginningChanged: {
            if(currentRoom && atYBeginning) currentRoom.getPreviousContent()
        }

    }

