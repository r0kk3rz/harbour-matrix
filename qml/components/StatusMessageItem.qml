import QtQuick 2.0
import Sailfish.Silica 1.0

Item {

    property var itemText

    x: parent.x + Theme.paddingLarge + Theme.paddingSmall
    width: parent.width - x
    height: textMessage.height

    TextEdit {
        id: textMessage

        width: parent.width
        height: contentHeight // + Theme.paddingMedium
        verticalAlignment: Text.AlignBottom
        readOnly: true
        textFormat: TextEdit.RichText
        text: "<style>a:link { color: " + Theme.highlightColor + "; }</style>" + itemText
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeExtraSmall
        onLinkActivated: Qt.openUrlExternally(link)
    }
}
