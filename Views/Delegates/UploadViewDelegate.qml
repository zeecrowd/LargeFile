import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.1

import "../Tools.js" as Tools

Rectangle
{
    height : 20
    width : parent.width
    color : index % 2 ? "lightgrey" : "white"

    Row
    {
        anchors.fill: parent
        Label
        {
            id :lbStatus
            height : 20 ;
            width : 200 ;
            text: status ;
            color : "black";
            font.pixelSize:  16
        }

        Label
        {
            id : lbName
            height : 20 ;
            width : 200 ;

            text: name ;
            color : "black";
            font.pixelSize:  16
        }

        Label
        {
            height : 20 ;

            width  : 400

            text: message ;
            color : "black";
            font.pixelSize:  16
        }

//        Button
//        {
//            height : 20 ;
//            width  : status === "NeedValidation" ? 80 : 0
//            text: "Validate"

//            onClicked:
//            {
//                Tools.setPropertyinListModel(uploadingFiles,"status","Validated",function (x) { return x.name === name });
//                Tools.setPropertyinListModel(uploadingFiles,"validated",true,function (x) { return x.name === name });
//                Tools.setPropertyinListModel(uploadingFiles,"message","",function (x) { return x.name === name });
//                mainView.restartUpload(name,localPath);
//            }
//        }

        Button
        {
            height : 20 ;
            width  : 80
            text: "Cancel"

            onClicked:
            {
                mainView.cancelUpload(name);
            }
        }
    }

    ProgressBar
    {
        anchors.fill: parent
        visible : progress > 0
        opacity: 0.5

        height : parent.height
        width  : parent.width

        minimumValue: 0
        maximumValue: 100
        value       : progress
    }

}
