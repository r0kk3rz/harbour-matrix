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

    showNavigationIndicator: false

    property bool isLoaded: false


    /*
    onStatusChanged: {
        if (status == PageStatus.Active
                && pageStack._currentContainer.attachedContainer === null) {
            pageStack.popAttached(Qt.resolvedUrl("../pages/DetailsPage.qml"))
        }
    }
    */


    /*
    Behavior on opacity {
        NumberAnimation {
            duration: 400
        }
    }
    */
    RemorsePopup {
        id: remorse
    }

    function syncDone() {
        if (isLoaded == false) {
            console.log("Initial Syncing Done")
            isLoaded = true
        }
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
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.left
                    radius: 0.22
                    falloffRadius: 0.18
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageStack.navigateBack()
                        }
                    }
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

                    AvatarBubble {
                        id: bubble
                        anchors.left: parent.left
                        height: parent.height
                        width: height
                        anchors.verticalCenter: parent.verticalCenter

                        imageVisible: avatar != ""
                        imageSource: avatar

                        rectLabelVisible: !imageVisible
                        rectColor: imageVisible ? Theme.secondaryColor : stringToColour(
                                                      display)
                        rectLabelText: display.charAt(0).toUpperCase()
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
