import QtQuick 2.2

FileTextDelegate
{
    text : downloadStatus
    //isBusy : item != null && item !== undefined ?  item.busy : false
    position : index

    onClicked : mainView.openFile(item)
    notifyPressed: true
}

