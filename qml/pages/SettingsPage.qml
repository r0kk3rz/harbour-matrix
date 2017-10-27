import QtQuick 2.0
import Sailfish.Silica 1.0
//import Matrix 1.0


Page {
    id: settingsPage

    Column {
        width: parent.width -x
        spacing: Theme.paddingMedium
        x: Theme.paddingLarge
        PageHeader {title: "Settings"}
        TextSwitch {
            id: colorSwitch
            text: "Fancy colors"
            description: "Use fancy colors on user names"
            checked: useFancyColors
            automaticCheck: false
            onClicked: {
                useFancyColors = !useFancyColors
                settings.setValue("fancycolors", useFancyColors)
            }
        }
        TextSwitch {
            id: bgSwitch
            text: "Dark background"
            description: "Use dark background on chat"
            checked: useBlackBackground
            automaticCheck: false
            onClicked: {
                useBlackBackground = !useBlackBackground
                settings.setValue("blackbackground", useBlackBackground)
            }
        }
        //Item {height: Theme.itemSizeMedium} //separator

        /*Button {
            text: "About"
            anchors.horizontalCenter: parent.horizontalCenter
        }*/
        SectionHeader { text: "About" }
        Label {
            text: "Matriksi 0.1"
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor
            width: parent.width *0.8
        }
        Label {
            text: "Unofficial Matrix.org client for Sailfish OS"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.highlightColor
            width: parent.width
        }
        Label {
            text: 'Browse our rooms and post new messages. Rooms are updated in real-time when new messages are posted.'
            font.pixelSize: Theme.fontSizeSmall
            width: parent.width
            wrapMode: Text.WordWrap
        }
        Label {
            text: 'This software uses: <ul><li>libqmatrixclient library</li><li>Tensor - parts of code</li></ul>'
            font.pixelSize: Theme.fontSizeSmall
            width: parent.width
            wrapMode: Text.WordWrap
        }
        Label {
            text: 'Source code and issues in <a href="https://github.com/anttsam/matriksi">Github</a>.'
            font.pixelSize: Theme.fontSizeSmall
            linkColor: Theme.highlightColor
            onLinkActivated: Qt.openUrlExternally(link)
        }

    }


}
