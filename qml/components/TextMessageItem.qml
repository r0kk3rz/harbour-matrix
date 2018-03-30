import QtQuick 2.0
import Sailfish.Silica 1.0

Item {

    property var itemText

    x: parent.x + Theme.paddingLarge + Theme.paddingMedium
    width: parent.width - x
    height: textMessage.height

    Text {
        id: textMessage
        width: parent.width
        height: contentHeight + Theme.paddingMedium
        text: itemText
        verticalAlignment: Text.AlignBottom
        horizontalAlignment: Text.AlignLeft
        color: Theme.primaryColor
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeSmall
    }
}
