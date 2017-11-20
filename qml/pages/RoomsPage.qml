/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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

    RoomListModel {
        id: rooms
    }

    function setConnection(conn) {
        rooms.setConnection(conn)
    }

    function init() {
        initialised = true
        var found = false
        for(var i = 0; i < rooms.rowCount(); i++) {
            if(rooms.roomAt(i).canonicalAlias() === "#tensor:matrix.org") {
                roomListView.currentIndex = i
                enterRoom(rooms.roomAt(i))
                found = true
            }
        }
        if(!found) joinRoom("#tensor:matrix.org")
    }

    function refresh() {
        if(roomListView.visible)
            roomListView.forceLayout()
    }

    SilicaListView {
        id: roomListView
        model: rooms
        width: parent.width
        height: parent.height - textEntry.height

        anchors.fill: parent

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
               text: "Settings"
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

        delegate: ListItem {
            width: parent.width
            contentHeight: Theme.itemSizeSmall

            Item {
                height: parent.height

                AvatarImage {
                    id: roomAvatar
                    iconSource: avatar
                    iconSize: Theme.paddingLarge + Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    id: roomLabel
                    text:(rooms.roomAt(index).name == "") ? display : rooms.roomAt(index).name
                    color: pressed? Theme.secondaryColor: (rooms.roomAt(index).highlightCount > 0) ? Theme.highlightColor : Theme.primaryColor
                    //elide: Text.ElideRight
                    font.bold: (rooms.roomAt(index).highlightCount > 0)
                    //anchors.margins: 2
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.left: roomAvatar.right
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeMedium
                }
            }

            onClicked: {
                roomListView.currentIndex = index
                enterRoom(rooms.roomAt(index))
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
        setConnection(connection)
        enterRoom.connect(roomView.setRoom)
        joinRoom.connect(connection.joinRoom)
    }
  }
