import QtQuick 2.2
import Sailfish.Silica 1.0

Label {
    property string labelText
    property int labelFontSize: Theme.fontSizeMedium

    anchors { left: parent.left; right: parent.right; leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin }
    font.pixelSize: labelFontSize
    wrapMode: Text.WordWrap
    text: labelText
}
