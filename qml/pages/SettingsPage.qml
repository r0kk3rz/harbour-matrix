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
    }


}
