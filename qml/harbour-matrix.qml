/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
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

    Connection {
        id: connection
        onReconnected: {
            console.log("reconnected!")
            connectionActive = true
        }
        onConnectionError: {
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
    Settings   { id: settings }

    function resync() {
        if(!initialised) {
            login.visible = false
            //mainView.visible = true
            //roomListItem.init()
            initialised = true
        }
        connection.sync(30000)
    }

    function login(user, pass, connect) {
        if(!connect) connect = connection.connectToServer

        connection.connected.connect(function() {
            settings.setValue("user",  connection.userId())
            settings.setValue("token", connection.token())

            connection.connectionError.connect(connection.reconnect)
            connection.syncDone.connect(resync)
            connection.reconnected.connect(resync)

            connection.sync()
        })

        var userParts = user.split(':')
        if(userParts.length === 1 || userParts[1] === "matrix.org") {
            connect(user, pass)
        } else {
            connection.resolved.connect(function() {
                connect(user, pass)
            })
            connection.resolveError.connect(function() {
                console.log("Couldn't resolve server!")
            })
            connection.resolveServer(userParts[1])
        }
    }

    function loadSettings (){
        if (settings.contains("fancycolors")) useFancyColors = settings.getSetting("fancycolors")
        else settings.setValue("fancycolors", useFancyColors)
        if (settings.contains("blackbackground")) useBlackBackground = settings.getSetting("blackbackground")
        else settings.setValue("blackbackground", useBlackBackground)
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

    Login {
        id: login
        window: window
        anchors.fill: parent
        Component.onCompleted: {
            var user =  settings.value("user")
            var token = settings.value("token")
            if(user && token) {
                login.login(true)
                window.login(user, token, connection.connectWithToken)
            }
        }
    }

}

