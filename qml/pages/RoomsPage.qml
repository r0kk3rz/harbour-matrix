import QtQuick 2.2
import Sailfish.Silica 1.0
import Matrix 1.0
import "../components/custom"

Page {
    id: page

    signal enterRoom(var room)
    signal joinRoom(string name)

    enabled: initialised
    opacity: initialised ? 1 : 0

    property bool isLoaded: false

    Behavior on opacity {
        NumberAnimation {
            duration: 400
        }
    }

    RemorsePopup {
        id: remorse
    }

    function syncDone() {
        if (isLoaded == false) {
            console.log("Initial Syncing Done")
            isLoaded = true
        }
    }

    function stringToColour(str) {
        var hash = 0
        for (var i = 0; i < str.length; i++) {
            hash = str.charCodeAt(i) + ((hash << 5) - hash)
        }
        var colour = '#'
        for (var i = 0; i < 3; i++) {
            var value = (hash >> (i * 8)) & 0xFF
            colour += ('00' + value.toString(16)).substr(-2)
        }
        return colour
    }

    function refresh() {
        if (roomListView.visible)
            roomListView.forceLayout()
    }

    SilicaListView {
        id: roomListView
        model: roomsProxy
        anchors.fill: parent
        signal sectionClicked(string name)
        currentIndex: -1

        header: PageHeader {
            title: qsTr("Rooms")

            Item {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                BusyIndicator {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    visible: running
                    running: isLoaded == false
                    size: isLoaded ? 0 : BusyIndicatorSize.Medium
                }

                GlassItem {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: connectionActive ? "lightgreen" : "pink"
                    cache: false
                    visible: isLoaded
                }
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Logout")
                onClicked: remorse.execute(qsTr("Logging out"), function () {
                    initialised = false
                    connection.logout()
                    scriptLauncher.launchScript()
                    pageStack.clear()
                    pageStack.replace(Qt.resolvedUrl("../harbour-matrix.qml"))
                })
            }

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
        }

        section.property: "tags"
        section.criteria: ViewSection.FullString
        section.delegate: ExpandingSection {
            title: qsTrId(section)
            onExpandedChanged: {
                roomListView.sectionClicked(section)
            }
        }

        delegate: ListItem {
            id: item
            width: parent.width
            property bool collapsed: false
            contentHeight: !collapsed ? Theme.itemSizeSmall : 0
            visible: contentHeight > 0

            Behavior on contentHeight {
                NumberAnimation {
                    duration: 200
                }
            }

            Connections {
                target: item.ListView.view
                onSectionClicked: if (item.ListView.section === name)
                                      collapsed = !collapsed
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.topMargin: Theme.paddingSmall
                anchors.bottomMargin: Theme.paddingSmall

                Item {
                    anchors.fill: parent

                    Rectangle {
                        id: bubble
                        height: parent.height
                        width: height
                        radius: height / 2
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: roomAvatar.visible == false ? stringToColour(
                                                                 display) : Theme.secondaryColor

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: display.charAt(0).toUpperCase()
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                            visible: roomAvatar.visible == false
                        }

                        AvatarImage {
                            id: roomAvatar
                            iconSource: avatar
                            iconSize: parent.height
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: avatar != ""
                        }
                    }

                    Label {
                        anchors.left: bubble.right
                        anchors.right: counterLabel.left
                        anchors.margins: Theme.paddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        truncationMode: TruncationMode.Fade

                        text: display
                        color: highlightcount > 0 ? Theme.highlightColor : Theme.primaryColor
                        font.bold: unread
                    }
                    Label {
                        anchors.right: inviteButton.left
                        anchors.margins: visible ? Theme.horizontalPageMargin : 0
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        id: counterLabel
                        text: highlightcount
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeSmall
                        visible: highlightcount > 0
                        width: visible ? implicitWidth : 0
                    }

                    IconButton {
                        id: inviteButton
                        Image {
                            source: "image://theme/icon-m-acknowledge"
                        }
                        onClicked: joinRoom(roomid)
                        visible: tags == "m.invite"
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: visible ? Theme.iconSizeMedium : 0
                    }
                }
            }

            onClicked: {
                roomListView.currentIndex = index
                enterRoom(roomid)
                pageStack.push(roomView)
            }
        }
        footer: TextField {
            id: textEntry
            width: parent.width
            height: implicitHeight
            placeholderText: qsTr("Join room...")
            EnterKey.onClicked: {
                joinRoom(text)
                text = ""
            }
            enabled: isLoaded
            visible: isLoaded
        }
    }

    Connections {
        target: connection
        onSyncDone: syncDone()
    }

    Component.onCompleted: {
        enterRoom.connect(roomView.setRoom)
        joinRoom.connect(connection.joinRoom)
    }
}
