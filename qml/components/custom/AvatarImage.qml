import QtQuick 2.2
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0

Item {
    id: wrapper

    property string iconSource
    property int iconSize

    signal clicked()

    height: iconSize
    width: height

    Item {
        id: imageWrapper
        anchors {
            top: parent.top
            left: parent.left
        }

        height: iconSize

        Image {
            id: avatar
            source: wrapper.iconSource
            width: iconSize
            height: iconSize
            sourceSize: Qt.size(iconSize, iconSize)
            visible: false //(wrapper.userName) ? false : true
        }

        Image {
            id: mask
            source: "qrc:/res/circle.png"
            sourceSize: Qt.size(iconSize, iconSize)
            smooth: true
            visible: false
        }
        
        OpacityMask { // create a circle image
            anchors.fill: avatar
            source: avatar
            maskSource: mask
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: wrapper.clicked();
    }
  }

