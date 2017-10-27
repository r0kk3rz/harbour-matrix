import QtQuick 2.0
import Sailfish.Silica 1.0
import Matrix 1.0


SilicaListView {
        id: chatView
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        verticalLayoutDirection: ListView.BottomToTop
        model: MessageEventModel { id: messageModel }
        clip:true
        property Connection currentConnection: null
        property var currentRoom: null

        function setRoom(room) {
            currentRoom = room
            messageModel.changeRoom(room)
        }

        function setConnection(conn) {
            currentConnection = conn
            messageModel.setConnection(conn)
        }

        function sendLine(text) {
            if(!currentRoom || !currentConnection) return
            currentConnection.postMessage(currentRoom, "m.text", text)
        }
        header: TextField {
            id: textEntry
            width: parent.width
            //anchors.bottom: chatView.bottom
            //focus: true
            //textColor: "black"
            placeholderText: qsTr("Say something...")
            EnterKey.onClicked: {
                sendLine(text)
                textEntry.text = ""
            }

        }
        delegate: Item {
            id: myListItem
            property Item contextMenu
            property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem


            width: chatView.width
            height: menuOpen ? contextMenu.height + backgroundItem.height : backgroundItem.height

            BackgroundItem {
                id: backgroundItem
                width: chatView.width
                height: visible ? chattext.height : 0

                ListView.onAdd: AddAnimation {
                    target: backgroundItem
                }

                Label {
                    id: labelColumn
                    width: eventType == "message" ? (Screen.sizeCategory >= Screen.Large) ? parent.width * 0.2 : chatView.isPortrait ? parent.width*0.3 : parent.width * 0.2 :0
                    //width: parent.width * 0.3
                    height: parent.height
                    text: eventType == "message" ? author : ""
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall -2
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    height: parent.height - 2
                    width: labelColumn.width
                    anchors.centerIn: labelColumn
                    color: eventType == "message" ?  Theme.secondaryHighlightColor : "transparent"
                    opacity: 0.4
                }
                Label{

                    text: time.toLocaleTimeString("hh:mm:ss")
                    color: chattext.color //Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall -2
                    anchors.bottom: chattext.bottom
                    anchors.right: parent.right
                    opacity: 0.4
                }

                Label {
                    x: labelColumn.width+10
                    width: chatView.width -x
                    //height: contentHeight
                    id: chattext
                    text: content
                    color: eventType == "message" ? Theme.primaryColor: Theme.secondaryColor
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                   // textFormat: Text.RichText

                }
                onPressAndHold: {
                    if (!contextMenu)
                        contextMenu = contextMenuComponent.createObject(chatview)
                    chatview.textvalue = chattext.text
                    contextMenu.show(myListItem)
                }

            }


        }

        Component {
            id: contextMenuComponent
            ContextMenu {
                TextArea {
                    x: 10
                    width: page.width -x
                    //height: contentHeight
                    id: chattext
                    text: chatview.textvalue
                    color: Theme.highlightColor
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    //readOnly: true
                    Component.onCompleted: selectAll();
                }

            }
        }
        VerticalScrollDecorator {
            flickable: chatView
        }

        /*delegate: Row {
            id: message
            width: parent.width
            spacing: 8

            Label {
                id: timelabel
                text: time.toLocaleTimeString("hh:mm:ss")
                color: "grey"
            }
            Label {
                width: 64
                elide: Text.ElideRight
                text: eventType == "message" ? author : "***"
                color: eventType == "message" ? "grey" : "lightgrey"
                horizontalAlignment: Text.AlignRight
            }
            Label {
                text: content
                wrapMode: Text.Wrap
                width: parent.width - (x - parent.x) - spacing
                color: eventType == "message" ? "black" : "lightgrey"
            }
        }*/

        section {
            property: "date"
            labelPositioning: ViewSection.CurrentLabelAtStart
            delegate: Item {
                id: sectionItem
                width: parent.width
                height: childrenRect.height
                opacity: chatView.moving? 1:0
                Label {
                    width: parent.width
                    text: section.toLocaleString(Qt.locale())
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge

                    font.bold: true
                }
                Behavior on opacity { NumberAnimation { duration: 500}}
            }

        }

        onAtYBeginningChanged: {
            if(currentRoom && atYBeginning) currentRoom.getPreviousContent()
        }

    }

