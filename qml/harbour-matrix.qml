import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import Nemo.DBus 2.0
import "pages"
import Matrix 1.0

ApplicationWindow {
    initialPage: Component {
        DetailsPage {
        }
    }
    cover: undefined //Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All
    id: window

    property bool initialised: false
    property bool useFancyColors: true
    property bool useBlackBackground: false

    property bool connectionActive: false

    property string appName: "Matriksi"
    property string version: "0.9.7 Beta"

    property int syncCounter: 0

    Connections {
        target: connection

        onNetworkError: {
            console.log("Connection Error")
            connectionActive = false
        }
        onConnected: {
            console.log("connected!")
            connectionActive = true
        }
        onLoggedOut: {
            console.log("Logged out...")
            connectionActive = false
            login.abortLogin()
        }
        onLoginError: {
            console.log("Login Error")
            connectionActive = false
            login.abortLogin()
        }
        onSyncError: {
            console.log("Sync Error")
            connectionActive = false
        }
        onResolveError: {
            console.log("Resolve Error")
            connectionActive = false
            login.abortLogin()
        }
    }

    DBusAdaptor {
        service: 'org.harbour.matrix'
        iface: 'org.harbour.matrix'
        path: '/'

        xml: '  <interface name="org.harbour.matrix">\n' + '    <method name="openRoom">\n'
             + '      <arg name="roomid" direction="in" type="s">\n'
             + '        <doc:doc><doc:summary>id of room to open</doc:summary></doc:doc>\n'
             + '      </arg>\n' + '    </method>\n' + '  </interface>\n'

        function openRoom(roomid) {
            roomView.setRoom(roomid)
            pageStack.push(roomView)
            window.activate()
        }
    }

    function resync() {

        connectionActive = true

        syncCounter++
        if (syncCounter % 17 == 2) {
            connection.saveState()
        }

        connection.sync(10 * 1000)
    }

    function login(user, pass, connect) {
        if (!connect)
            connect = connection.connectToServer

        connection.connected.connect(function () {
            settings.setValue("user", connection.localUserId)
            settings.setValue("token", connection.accessToken)
            settings.setValue("device_id", connection.deviceId)
            settings.sync()

            connection.loadState()

            initialised = true
            login.visible = false

            connection.syncDone.connect(resync)
            connection.sync(30000)
        })

        var userParts = user.split(':')
        if (userParts.length === 1) {
            connect(user + ":matrix.org", pass, settings.value("device_id",
                                                               "sailfish"))
        } else {
            connect(user, pass, settings.value("device_id", "sailfish"))
        }
    }

    function loadSettings() {
        useFancyColors = settings.value("fancycolors", useFancyColors)
        useBlackBackground = settings.value("blackbackground",
                                            useBlackBackground)
    }

    function stringToHue(str) {
        var hash = 0
        if ((str).length === 0)
            return hash
        for (var i = 0; i < (str).length; i++) {
            hash = (str).charCodeAt(i) + ((hash << 5) - hash)
            hash = hash & hash
        }
        return Math.abs(360 / (hash % 360) % 1)
    }

    function stringToColour(str) {
        if (str) {
            return Qt.hsla(stringToHue(str), 0.5, 0.4, 1)
        }
        return Theme.primaryColor
    }

    RoomView {
        id: roomView
        Component.onCompleted: {
            loadSettings()
        }
    }
    SettingsPage {
        id: settingsPage
    }

    AboutPage {
        id: aboutPage
    }

    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-matrix/settings"
    }

    Login {
        id: login
        window: window
        anchors.fill: parent
        Component.onCompleted: {
            var user = settings.value("user", "")
            var token = settings.value("token", "")
            if (user != "" && token != "") {
                login.login(true)
                window.login(user, token, connection.connectWithToken)
            }
        }
    }
}
