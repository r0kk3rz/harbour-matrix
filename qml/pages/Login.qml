import QtQuick 2.0
import Sailfish.Silica 1.0
Item {
    property variant window

    property bool showstuff: true

    function login(pretend) {
        label.text = qsTr("Please wait...")
        if(!pretend) window.login(userNameField.text, passwordField.text)
        userNameField.enabled = false
        passwordField.enabled = false
        loginbutton.enabled = false
        showstuff = false
        userNameField.opacity = 0
        passwordField.opacity = 0
        loginbutton.opacity = 0
    }

    Column {
        width: parent.width /1.5
        anchors.centerIn: parent
        opacity: 0
        spacing: 18

        Item {
            width: parent.width
            height: 1
        }

        Item {
            width: 128
            height: 128
            anchors.horizontalCenter: parent.horizontalCenter
            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                antialiasing: true
                //source: "qrc:/logo.png"

                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 60000
                }
            }
            BusyIndicator {
                anchors.centerIn: parent
                running: !showstuff
                opacity: !showstuff ? 1:0
            }
        }

        Label { id: phantomLabel; visible: false }

        Label {
            id: label
            font.pixelSize: phantomLabel.font.pixelSize * 5/2
            text: qsTr("Matrix")
            color: "#888"
        }

        TextField {
            id: userNameField
            width: parent.width
            placeholderText: qsTr("Username")
        }


        TextField {
            id: passwordField
            echoMode: TextInput.Password
            width: parent.width
            placeholderText: qsTr("Password")
        }
        Button {
           id: loginbutton
            text: "Login"
            onClicked: login()

        }

        NumberAnimation on opacity {
            id: fadeIn
            to: 1.0
            duration: 1000
        }

        Component.onCompleted: fadeIn.start()
    }
}
