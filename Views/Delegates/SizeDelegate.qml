import QtQuick 2.0

FileTextDelegate
{
    position : index
    text : nbrPacket + " / " + totalPacket
//    isBusy : item != null && item !== undefined ?  item.busy : false
}
