import QtQuick 2.2
import Sailfish.Silica 1.0

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
        textEntry.text = ''
    }
    Rectangle {
        color: "Black"
        anchors.fill: parent
        visible: useBlackBackground
        opacity: 0.8
    }

    ChatRoom2 {
        id: chat
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
    }

    Component.onCompleted: {
        setConnection(connection)
    }
}
