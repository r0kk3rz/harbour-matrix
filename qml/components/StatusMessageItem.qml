import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property var itemText

    x: parent.x + Theme.paddingLarge + Theme.paddingMedium
    width: parent.width - x
    height: statusMessages.height

    Label {
        id: statusMessages
        horizontalAlignment: Text.AlignHCenter
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeExtraSmall
        height: lineCount * font.pixelSize + Theme.paddingMedium
        text: itemText
    }
}
