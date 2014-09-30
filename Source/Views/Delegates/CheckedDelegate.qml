import QtQuick 2.2
import QtQuick.Controls 1.0

Rectangle
{
    height : 40
    width : parent.width
//    color : item != null && item !== undefined && item.busy ? "lightgrey" : /*(index % 2 ? "#FFF2B7" :*/ "white" //)

    CheckBox
    {
        id : checkBox

        anchors
        {
            verticalCenter: parent.verticalCenter
            left    : parent.left
            leftMargin: 7
        }

  //      enabled : !item.busy

        onCheckedChanged:
        {

            largeFileGridViewId.setSelected(model.name,checked)
        }

    }


    function selectUnselect(val)
    {
        checkBox.checked = val;
    }

    Component.onCompleted :
    {
        //fodlerGridViewId.onSelectedAllChanged.connect(selectUnselect);
        checkBox.checked = model.isSelected;
    }

    Component.onDestruction:
    {
        //fodlerGridViewId.onSelectedAllChanged.disconnect(selectUnselect);
    }
}
