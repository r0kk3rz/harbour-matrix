import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property var itemContent
    property var type

    x: parent.x + Theme.paddingLarge + Theme.paddingMedium
    width: parent.width - x
    height: imageMessage.height

    Image {
        id: imageMessage
        visible: type == "image"
        source: visible ? itemContent : ""
        width: parent.width - (Theme.paddingLarge * 2)
        height: visible ? Theme.itemSizeHuge * 2 : 0
        fillMode: Image.PreserveAspectFit
    }

    Rectangle {
        visible: type == "file"
    }

    IconButton {
        id: downloadButton
        visible: type == "file" || type == "image"
        anchors.right: parent.right
        icon.source: "image://theme/icon-m-cloud-download"
        width: Theme.buttonWidthMedium
        height: visible ? Theme.itemSizeMedium : 0
    }
}
