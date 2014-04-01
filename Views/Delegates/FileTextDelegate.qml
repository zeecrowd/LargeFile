import QtQuick 2.0

Rectangle
{
    id : fileTextDelegate

    height : 40
    width : parent.width

    signal clicked()

    property bool notifyPressed : false
    property bool isBusy : false
    property int position : 0

//    color : isBusy ? "lightgrey" : /*(position % 2 ? "#FFF2B7" :*/ "white" //)
    property alias text : delegateId.text

//    onIsBusyChanged:
//    {
//        color = isBusy ? "lightgrey" : /*(position % 2 ? "#FFF2B7" :*/ "white" //);
//    }

    Text
    {
        id                          : delegateId
        color                       : "black"
        anchors.verticalCenter      : parent.verticalCenter
        anchors.left                : parent.left
        anchors.leftMargin          : 5
        font.pixelSize              : 16
        textFormat: Text.RichText

        onLinkActivated:
        {
//            if (!isBusy)
//                fileTextDelegate.clicked()
        }
     }
 }

