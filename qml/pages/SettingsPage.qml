import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
//import Matrix 1.0


Page {
    id: settingsPage

    ConfigurationGroup {
        id: settings
         path: "/apps/harbour-matrix/settings"
    }

    Column {
        width: parent.width -x
        spacing: Theme.paddingMedium
        x: Theme.paddingLarge
        PageHeader {title: "Settings"}
        TextSwitch {
            id: colorSwitch
            text: qsTr("Fancy colors")
            description: qsTr("Use fancy colors on user names")
            checked: useFancyColors
            automaticCheck: false
            onClicked: {
                useFancyColors = !useFancyColors
                settings.setValue("fancycolors", useFancyColors)
            }
        }
        TextSwitch {
            id: bgSwitch
            text: qsTr("Dark background")
            description: qsTr("Use dark background on chat")
            checked: useBlackBackground
            automaticCheck: false
            onClicked: {
                useBlackBackground = !useBlackBackground
                settings.setValue("blackbackground", useBlackBackground)
            }
        }

        SectionHeader { text: "About" }

        Label {
            anchors { left: parent.left; right: parent.right }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontSizeExtraSmall
            wrapMode: Text.WordWrap
            text: qsTr("Matriksi is an unofficial Matrix Client for SailfishOS and distributed under the GPLv3 license.")
        }

        Button {
            id: aboutbutton
            text: qsTr("About Matriksi")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
        }
    }


}
