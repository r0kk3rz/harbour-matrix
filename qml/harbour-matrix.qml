import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "pages"
import Matrix 1.0

ApplicationWindow
{
    initialPage: Component { RoomsPage { } }
    cover: undefined //Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All
    id: window

    property bool initialised: false
    property bool useFancyColors: true
    property bool useBlackBackground: false

    property bool connectionActive: false

    property string appName: "Matriksi"
    property string version: "0.6 Alpha"

    Connection {
        id: connection
        onReconnected: {
            console.log("reconnected!")
            connectionActive = true
        }
        onNetworkError: {
            console.log("Connection Error, reconnecting...")
            connection.reconnect();
            connectionActive = false
        }
        onConnected: {
            console.log("connected!")
            connectionActive = true
        }
        onLoggedOut: {
            console.log("Logged out...")
            connectionActive = false
        }
        onLoginError: {
            console.log("Login Error, reconnecting...")
            //connection.reconnect();
            connectionActive = false
        }


    }

    function resync() {
        if(!initialised) {
            login.visible = false
            initialised = true
        }
        connection.sync(30000)
    }

    function login(user, pass, connect) {
        if(!connect) connect = connection.connectToServer

        connection.connected.connect(function() {
            settings.setValue("user",  connection.userId())
            settings.setValue("token", connection.token())
            settings.sync()

            connection.syncDone.connect(resync)
            connection.reconnected.connect(resync)

            connection.sync()
        })

        var userParts = user.split(':')
        if(userParts.length === 1 || userParts[1] === "matrix.org") {
            connect(user, pass, "sailfish")
        } else {
            connection.resolved.connect(function() {
                connect(user, pass, "sailfish")
            })
            connection.resolveError.connect(function() {
                console.log("Couldn't resolve server!")
            })
            connection.resolveServer(userParts[1])
        }
    }

    function loadSettings (){
        useFancyColors = settings.value("fancycolors",useFancyColors)
        useBlackBackground = settings.value("blackbackground", useBlackBackground)
    }

    RoomView {
        id: roomView
        Component.onCompleted: {
            setConnection(connection)
            loadSettings()
        }
    }
    SettingsPage {
        id: settingsPage
    }

    AboutPage {
        id: aboutPage
    }

    ConfigurationGroup
    {
        id: settings
        path: "/apps/harbour-matrix/settings"
    }

    Login {
        id: login
        window: window
        anchors.fill: parent
        Component.onCompleted: {
            var user =  settings.value("user", "")
            var token = settings.value("token", "")
            if(user != "" && token != "") {
                login.login(true)
                window.login(user, token, connection.connectWithToken)
            }
        }
    }

}

