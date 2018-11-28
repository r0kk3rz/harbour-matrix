import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
    property alias rectColor: rect.color
    property alias rectLabelVisible: label.visible
    property alias rectLabelText: label.text

    property alias imageVisible: roomAvatar.visible
    property alias imageSource: roomAvatar.iconSource

    Rectangle {
        id: rect
        anchors.fill: parent
        radius: height / 2

        Label {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: true
            font.pixelSize: parent.width * 0.7
            visible: root.rectLabelVisible
        }
    }

    AvatarImage {
        id: roomAvatar
        iconSize: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
