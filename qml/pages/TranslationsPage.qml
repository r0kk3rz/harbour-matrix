import QtQuick 2.2
import Sailfish.Silica 1.0
import "../js/util.js" as Util

Page {
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: transColumn.height

        VerticalScrollDecorator {}

        Column {
            id: transColumn
            width: parent.width
            spacing: Theme.paddingLarge
            
            PageHeader { title: qsTr("Translators") }

            IconTextButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Carlos Gonzalez"
                iconSource: "qrc:/res/icon-spain.png"
            }
         }
    }
}           
