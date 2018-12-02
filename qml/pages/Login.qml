import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components/textlabel"

Item {
    property variant window

    property bool showstuff: true

    function login(pretend) {
        label.text = qsTr("Please wait...")
        if (!pretend)
            window.login("@" + userNameField.text, passwordField.text)
        userNameField.enabled = false
        passwordField.enabled = false
        loginbutton.enabled = false
        accountbutton.enabled = false
        showstuff = false
        userNameField.opacity = 0
        passwordField.opacity = 0
        loginbutton.opacity = 0
        accountbutton.opacity = 0
    }

    function abortLogin() {
        label.text = qsTr("Matrix")
        userNameField.enabled = true
        passwordField.enabled = true
        loginbutton.enabled = true
        accountbutton.enabled = true
        showstuff = true
        userNameField.opacity = 1
        passwordField.opacity = 1
        loginbutton.opacity = 1
        accountbutton.opacity = 1
    }

    Column {
        width: parent.width / 1.5
        anchors.centerIn: parent
        opacity: 0
        spacing: 18

        Item {
            width: parent.width
            height: 1
        }

        Item {
            width: Theme.iconSizeExtraLarge
            height: Theme.iconSizeExtraLarge
            anchors.horizontalCenter: parent.horizontalCenter
            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                antialiasing: true
                source: "qrc:/res/harbour-matrix.png"

                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 60000
                }
            }

            BusyIndicator {
                size: BusyIndicatorSize.Large
                anchors.centerIn: parent
                running: !showstuff
                opacity: !showstuff ? 1 : 0
            }
        }

        Label {
            id: label
            font.pixelSize: Theme.fontSizeExtraLarge
            text: qsTr("Matriksi")
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#888"
        }

        TextField {
            id: userNameField
            width: parent.width
            placeholderText: qsTr("User Name or Matrix ID:")
            label: qsTr("username[:server][:port]")
        }

        TextField {
            id: passwordField
            echoMode: TextInput.Password
            width: parent.width
            placeholderText: qsTr("Password:")
        }

        Button {
            id: loginbutton
            text: qsTr("Login")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: login()
        }

        Button {
            id: accountbutton
            text: qsTr("Create an Matrix account")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                Qt.openUrlExternally("https://riot.im/app/#/register")
            }
        }

        NumberAnimation on opacity {
            id: fadeIn
            to: 1.0
            duration: 1000
        }

        Component.onCompleted: fadeIn.start()
    }
}
