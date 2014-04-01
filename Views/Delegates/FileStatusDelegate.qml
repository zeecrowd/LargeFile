import QtQuick 2.0

FileTextDelegate
{
    text : status
    //isBusy : item != null && item !== undefined ?  item.busy : false
    position : index

    onClicked : mainView.openFile(item)
    notifyPressed: true

//    Rectangle
//    {
//        anchors.top : parent.top
//        anchors.bottom : parent.bottom
//        anchors.left    : parent.left
//        opacity : 0.5
//        visible : item.queryProgress > 0
//        color   : "green"

//        width  : parent.width * item.queryProgress / 100
//    }
}

