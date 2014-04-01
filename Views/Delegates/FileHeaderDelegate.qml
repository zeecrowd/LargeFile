import QtQuick 2.0

Item
{
    height  : 30
    width   : parent.width

    property alias text : theText.text

    Rectangle
    {
        width       : parent.width
        height      : 25
        anchors.top : parent.top
        color       : "lightBlue"

        radius      : 3

        Text
        {
            id                          : theText
            anchors.centerIn            : parent
        }
    }
}
