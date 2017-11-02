import QtQuick 2.1
import Sailfish.Silica 1.0
import "../components/custom"

Page
{
    id: aboutpage
    allowedOrientations: Orientation.Portrait

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: content.height

        Column
        {
            id: content
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader
            {
                id: pageheader
                title: qsTr("About Matriksi")
            }

            Image
            {
                id: sglogo
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:/res/harbour-matrix.png"
            }

            Column
            {
                anchors { left: parent.left; right: parent.right }

                Label
                {
                    id: sgswname
                    anchors { left: parent.left; right: parent.right }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    font.pixelSize: Theme.fontSizeLarge
                    text: "Matriksi"
                }

                Label
                {
                    id: sgversion
                    anchors { left: parent.left; right: parent.right }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    text: { window.appName + " v" + window.version }
                }

                Label
                {
                    id: sginfo
                    anchors { left: parent.left; right: parent.right }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    text: qsTr("An unofficial Matrix Client for SailfishOS")
                }

                Label {
                    anchors { left: parent.left; right: parent.right }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.WordWrap
                    text: qsTr("Matriksi is an unofficial Matrix Client for SailfishOS and distributed under the GPLv3 license.")
                }
            }

            Column
            {
                anchors { left: parent.left; right: parent.right; topMargin: Theme.paddingExtraLarge }
                spacing: Theme.paddingSmall

                Button
                {
                    id: developersbutton
                    text: qsTr("Developers")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: pageStack.push(Qt.resolvedUrl("DevelopersPage.qml"))
                }
                
                Button
                {
                   id: donatebutton
                   text: qsTr("Donate with Paypal")
                   anchors.horizontalCenter: parent.horizontalCenter
                   onClicked: { Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6Z4P9MAAD996W");
                   }
                }

                Button
                {
                    id: translationsbutton
                    text: qsTr("Translations")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: pageStack.push(Qt.resolvedUrl("TranslationsPage.qml"), { "context": aboutpage.context })
                }
             }
         }
      }
   }
