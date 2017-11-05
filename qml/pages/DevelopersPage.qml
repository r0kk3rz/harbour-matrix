import QtQuick 2.1
import Sailfish.Silica 1.0
import "../components/about"

Page
{
    id: developerspage
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
                title: qsTr("Developers")
            }

            CollaboratorsLabel {
                title: qsTr("New developers");
                labelData: [ "Rudi Timmermans", "r0kk3rz"  ]
            }

            CollaboratorsLabel {
                title: qsTr("Previous developer");
                labelData: [ "Sami Anttila" ]
            }
        }
    }
}
