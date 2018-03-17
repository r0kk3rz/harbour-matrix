import QtQuick 2.2
import Sailfish.Silica 1.0
import Matrix 1.0
import "../components/custom"

Page {
    id: page

    signal enterRoom(var room)
    signal joinRoom(string name)

    enabled: initialised
    opacity: initialised ? 1: 0

    Behavior on opacity {NumberAnimation{duration: 400}}

    RemorsePopup { id: remorse }

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

    function refresh() {
        if(roomListView.visible)
            roomListView.forceLayout()
    }

    SilicaListView {
        id: roomListView
        model: roomsProxy
        width: parent.width
        height: parent.height - textEntry.height
        signal sectionClicked(string name)

        anchors.top: parent.top

        clip: true
        currentIndex: -1

        header: PageHeader {
            title: qsTr("Rooms")
            GlassItem {
                color: connectionActive ? "green" : "red"
                cache: false
                anchors.verticalCenter: parent.verticalCenter
            }

        }

        PullDownMenu {

           MenuItem {
                text: qsTr("About Matriksi")
                onClicked: pageStack.push(aboutPage)
            }

           MenuItem {
               text: qsTr("Settings")
               onClicked: {
                   pageStack.push(settingsPage)
            }
         }

           MenuItem {
               text: qsTr("Logout")
               onClicked: remorse.execute(qsTr("Logging out"), function(){
                   connection.logout()
                   scriptLauncher.launchScript()
                   pageStack.clear();
                   pageStack.replace(Qt.resolvedUrl("../harbour-matrix.qml"));
             });
          }
       }

        section.property: "tags"
        section.criteria: ViewSection.FullString
        section.delegate: ListItem {
            Row {
                spacing: Theme.paddingMedium
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    source: "image://theme/icon-m-down"
                }

                Label{
                    text: qsTr(section)
                    font.bold: true
                    font.pointSize: Theme.fontSizeLarge
                }
            }

            onClicked: roomListView.sectionClicked(section)
        }

        delegate: ListItem {
            id: item
            width: parent.width
            contentHeight: visible ? Theme.itemSizeSmall : 0

            Behavior on contentHeight
            {
                NumberAnimation { duration: 200 }
            }

            Connections {
                target: item.ListView.view
                onSectionClicked: if (item.ListView.section === name) visible = !visible;
            }

            Item {
                height: parent.height
                x: Theme.paddingMedium
                width: parent.width - x-x

                Row {
                    spacing: Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        id: bubble
                        height: Theme.itemSizeSmall - Theme.paddingMedium
                        width: height
                        radius: height/2
                        color: roomAvatar.visible == false ? stringToColour(display): "white"

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: display.charAt(0).toUpperCase()
                            font.bold: true
                            font.pointSize: Theme.fontSizeLarge
                            visible: roomAvatar.visible == false
                        }

                        AvatarImage {
                            id: roomAvatar
                            iconSource: avatar
                            iconSize: parent.height + 2
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: avatar != ""
                        }
                    }

                    Label {
                        text: display
                        color: highlightcount > 0 ? Theme.highlightColor : Theme.primaryColor
                        font.bold: unread
                        anchors.leftMargin: Theme.paddingMedium
                        font.pointSize: Theme.fontSizeMedium
                    }
                    Label {
                        text: highlightcount
                        color: Theme.highlightColor
                        font.pointSize: Theme.fontSizeSmall
                        visible: highlightcount > 0
                    }

                    Button {
                        Image{source: "image://theme/icon-m-like"}
                        onClicked: joinRoom(roomid)
                        visible: tags == "m.invite"
                    }
                }
            }

            onClicked: {
                roomListView.currentIndex = index
                enterRoom(roomid)
                pageStack.push(roomView)
            }
        }
    }

    TextField {
        id: textEntry
        width: parent.width
        anchors.bottom: parent.bottom
        placeholderText: qsTr("Join room...")
        EnterKey.onClicked: { joinRoom(text); text = "" }
    }

    Component.onCompleted: {
        enterRoom.connect(roomView.setRoom)
        joinRoom.connect(connection.joinRoom)
    }
  }
