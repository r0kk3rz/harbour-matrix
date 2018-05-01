import QtQuick 2.0
import Sailfish.Silica 1.0

Item {

    property var itemText

    x: parent.x + Theme.paddingLarge + Theme.paddingMedium
    width: parent.width - x
    height: textMessage.height

    TextEdit {
        id: textMessage

        width: parent.width
        height: contentHeight + Theme.paddingMedium
        verticalAlignment: Text.AlignBottom
        horizontalAlignment: Text.AlignLeft

        readOnly: true
        textFormat: TextEdit.RichText
        text: itemText
        wrapMode: Text.WordWrap
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeSmall
    }
}
