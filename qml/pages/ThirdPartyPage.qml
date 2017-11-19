import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components/about"

Page
{
    id: thirdpartypage
    allowedOrientations: Orientation.Portrait

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: content.height

        VerticalScrollDecorator { flickable: parent }

        Column
        {
            id: content
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader
            {
                id: pageheader
                title: qsTr("Third Party")
            }

            ThirdPartyLabel
            {
                title:"Libqmatrixclient"
                copyright: qsTr("The LGPL-2.1 license")
                licenselink: "https://github.com/davidar/libqmatrixclient"
            }
        }
    }
}
