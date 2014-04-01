import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import "./Delegates"
import "Tools.js" as Tools

ScrollView
{
    anchors.fill: parent

    id : largeFileGridViewId

    function setModel(model)
    {
        splitView.setModel(model)
    }

    // All files are selected
    signal selectedAllChanged(bool val);

    Flickable
    {
        anchors.fill: parent

        contentHeight: filesNameListView.contentHeight

        SplitView
        {
            id : splitView
            anchors.fill : parent
            orientation: Qt.Horizontal

            handleDelegate: Rectangle { width: 1; color: "white"}

            function setModel(model)
            {
//                filesCheckListView.model = model;
                filesNameListView.model = model;
                filesStatusListView.model = model;
                filesSizeListView.model = model;
            }

//            ListView
//            {
//                Component
//                {
//                    id : headerCheckComponent
//                    Item
//                    {
//                        height  : 30;
//                        width   : parent.width;

//                        Rectangle
//                        {
//                            width       : parent.width
//                            height      : 25
//                            anchors.top : parent.top
//                            color       : "lightBlue"

//                            radius      : 3

//                            CheckBox
//                            {
//                                id : allSelected
//                                anchors.verticalCenter: parent.verticalCenter
//                                anchors.left    : parent.left
//                                anchors.leftMargin: 7
//                                enabled : !item.busy
//                                onCheckedChanged:
//                                {
//                                    fodlerGridViewId.selectedAllChanged(checked);
//                                }
//                            }
//                        }
//                    }
//                }

//                id                  : filesCheckListView
//                spacing             : 10
//                contentY            : filesCalculateDateListView.contentY
//                Layout.minimumWidth : 25
//                Layout.maximumWidth : 25

//                model       : parent.model
//                interactive : false

//                delegate    : CheckedDelegate {}

//                header : headerCheckComponent
//            }


            ListView
            {
                id : filesNameListView
                spacing             : 10
                contentY            : filesSizeListView.contentY
                Layout.minimumWidth : 100
                Layout.fillWidth    : true
                model               : parent.model
                interactive         : false
                delegate            : FileNameDelegate {}

                header              : FileHeaderDelegate { text :  "Name" }
            }

            ListView
            {
                id : filesStatusListView
                spacing             : 10
                contentY            : filesSizeListView.contentY
                Layout.minimumWidth : 100
                Layout.fillWidth    : true
                model               : parent.model
                interactive         : false
                delegate            : FileStatusDelegate {}

                header              : FileHeaderDelegate { text :  "Status" }
            }

            ListView
            {
                id                  : filesSizeListView
                spacing             : 10
                Layout.minimumWidth : 100
                model               : parent.model
                interactive         : false
                delegate            : SizeDelegate {}
                header              : FileHeaderDelegate { text :  "Size" }
            }

        }
    }
}
