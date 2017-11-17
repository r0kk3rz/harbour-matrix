import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components/textlabel"


Page {
    id: settingsPage

    Column {
        width: parent.width -x
        spacing: Theme.paddingMedium
        x: Theme.paddingLarge

        PageHeader {title: "Settings"}

        SectionHeader{ text: qsTr("Matriksi Settings") }

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

       SectionHeader{ text: qsTr("Account") }            

        TextLabel { labelText: qsTr("Please restart Matriksi in order to log in with another account.") }

        Button {
           text: qsTr("Logout")
           anchors.horizontalCenter: parent.horizontalCenter
           onClicked: { remorse.execute("Logging out", function() { scriptLauncher.launchScript() })
           }
       }

        RemorsePopup {
            id: remorse
        }
    }
 }
