import QtQuick 2.2

FileTextDelegate
{
    Rectangle
    {
        anchors.top : parent.top
        anchors.left : parent.left
        anchors.bottom: parent.bottom

        width : parent.width * (downloadPacket / totalPacket)

        color : downloadPacket < totalPacket ? "orange " : "lightgreen"
        opacity : 0.5
    }

    text : downloadPacket + "/" + totalPacket
    position : index

    onClicked : mainView.openFile(item)
    notifyPressed: true
}

