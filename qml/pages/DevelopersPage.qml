import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components/about"

Page
{
    id: developerspage

    Column
        {
            id: content
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader
            {
                id: pageheader
                title: qsTr("harbour-matrix developers")
            }

            CollaboratorsLabel {
                title: qsTr("Developers");
                labelData: [ "r0kk3rz" ]
            }

            CollaboratorsLabel {
                title: qsTr("Previous developers");
                labelData: [ "Xray2000", "AlmAck", "Anttsam" ]
            }

            CollaboratorsLabel {
                title: qsTr("Contributors");
                labelData: [ "minitreintje", "KitsuneRal" ]
            }
        }
    }
