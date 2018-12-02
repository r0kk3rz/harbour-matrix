import QtQuick 2.5
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

Item {
    id: root
    signal clicked()
    property alias enabled: ma.enabled
    property alias source: icon.source
    property int margins
    Image {
        id: icon
        anchors.fill: parent
        anchors.margins: root.margins
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size( parent.width, parent.height )
        visible: false
        smooth: true
    }
    ColorOverlay {
        anchors.fill: icon
        source: icon
        color: root.enabled ? (ma.pressed ? Theme.highlightColor : Theme.primaryColor) : Theme.highlightColor
    }
    opacity: root.enabled ? 1 : Theme.highlightBackgroundOpacity
    MouseArea {
        id: ma
        anchors.fill: parent
        onClicked: {
            root.clicked()
        }
    }
}
