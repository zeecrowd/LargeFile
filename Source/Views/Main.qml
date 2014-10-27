/**
* Copyright (c) 2010-2014 "Jabber Bees"
*
* This file is part of the LargeFile application for the Zeecrowd platform.
*
* Zeecrowd is an online collaboration platform [http://www.zeecrowd.com]
*
* LargeFile is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0

//import "./Delegates"


import "Tools.js" as Tools
import "Main.js" as Presenter

import ZcClient 1.0 as Zc

Zc.AppView
{
    id : mainView

    anchors.fill : parent

    participantMenuActions : [
    ]


    toolBarActions : [
        Action {
            id: closeAction
            shortcut: "Ctrl+X"
            iconSource: "qrc:/LargeFile/Resources/close.png"
            tooltip : "Close Aplication"
            onTriggered:
            {
                mainView.close();
            }
        }
        ,
        Action {
            id: importAction
            shortcut: "Ctrl+I"
            iconSource: "qrc:/LargeFile/Resources/export.png"
            tooltip : "Put pictures on the cloud"
            onTriggered:
            {
                mainView.state = "putOnCloud"
                fileDialog.selectMultiple = false;
                fileDialog.selectFolder = false
                fileDialog.open()
            }
        }
        ,
        Action {
            id: deleteAction
            shortcut: "Ctrl+D"
            iconSource: "qrc:/LargeFile/Resources/bin.png"
            tooltip : "Delete File"
            onTriggered:
            {
                mainView.deleteSelectedFiles();
            }
        }
        ,
        Action {
            id: openLocalAction
            shortcut: "Ctrl+O"
            iconSource: "qrc:/LargeFile/Resources/folder.png"
            tooltip : "Open local folder"
            onTriggered:
            {
                documentFolder.openLocalPath();
            }
        }
    ]


    Zc.AppNotification
    {
        id : appNotification
    }

    onIsCurrentViewChanged :
    {
        if (isCurrentView == true)
        {
            appNotification.resetNotification();
        }
    }

    Zc.CrowdActivity
    {
        id : activity

        Zc.CrowdActivityItems
        {
            id         : itemsFileList
            name       : "ItemsLargeFileList"
            persistent : true

            Zc.QueryStatus
            {
                id : itemsFileListQueryStatus

                onCompleted :
                {

                    var allItems = itemsFileList.getAllItems();

                    if (allItems !== null)
                    {

                        Tools.forEachInArray(allItems, function(x) {
                            mainView.updateListFile(x,itemsFileList.getItem(x,""))
                        })

                    }


                    /*
                    ** Pending Upload
                    */

                    var uploadFilePending = documentFolder.getFilePathFromDirectory(".upload");

                    Tools.forEachInArray(uploadFilePending, function (x)
                    {
                        openUploadView();
                        var completePath = documentFolder.localPath + ".upload/" + x;
                        var fd = documentFolder.createFileDescriptorFromFile(completePath);
                        if (fd !== null)
                        {
                            Presenter.instance.startUpload(fd,"")
                        }
                    });

                    /*
                    **
                    */

                    var downloadedFiles = documentFolder.getFilePathFromDirectory(".");
                    var downloadedFilesProgress = documentFolder.getFilePathFromDirectory(".download");

                    Tools.forEachInListModel(listFileModel,function (x)
                    {

                        if (Tools.findInArray(downloadedFiles,function (y) {return y === x.name}) !== null)
                        {
                            Tools.setPropertyinListModel(listFileModel,"downloadPacket",x.totalPacket,function (y){ return y.name === x.name});
                            Tools.setPropertyinListModel(listFileModel,"downloadStatus","downloaded",function (y){ return y.name === x.name});
                        }
                        else
                        {
                            var progressfileCount = Tools.countInArray(downloadedFilesProgress,function (y) {return y.indexOf(x.name) !== -1});

                            if ( progressfileCount > 0)
                            {
                                Tools.setPropertyinListModel(listFileModel,"downloadPacket",progressfileCount,function (z)
                                {
                                    return z.name === x.name
                                }
                                );
                                Tools.setPropertyinListModel(listFileModel,"downloadStatus","incomplete",function (z)
                                {
                                    return z.name === x.name
                                }
                                );
                            }
                        }
                    });


                    //                    /*
                    //                    ** Pending deleting
                    //                    */


                    //                    Tools.forEachInListModel(listFileModel,function (x)
                    //                    {
                    //                        if (x.status === "Deleting")
                    //                        {

                    //                            for (var i = 0; i < x.totalPacket; i++)
                    //                            {
                    //                                var fd = documentFolder.getFileDescriptor(x.name + "_" + i ,true)
                    //                                Presenter.instance.startDelete(fd);
                    //                            }
                    //                        }
                    //                    });


                    splashScreenId.height = 0;
                    splashScreenId.width = 0;
                    splashScreenId.visible = false;
                }

                onErrorOccured :
                {
                    console.log(">> ERRROR " + error + " " + errorCause  + " " + errorMessage)
                }
            }

            onItemChanged :
            {
                mainView.updateListFile(idItem,getItem(idItem,""))
            }

            onItemDeleted :
            {
                Tools.removeInListModel(listFileModel, function (y) {return y.name === idItem })
            }
        }

        Zc.CrowdDocumentFolder
        {
            id   : documentFolder
            name : "LargeFileDocumentFolder"

            onImportFileToLocalFolderCompleted :
            {
                // import a file to the .upload directory finished
                if (localFilePath.indexOf(".upload") !== -1)
                {
                    var fileDescriptor = Presenter.instance.fileDescriptorToUpload[fileName];
                    Presenter.instance.fileDescriptorToUpload[fileName] = null;

                    Tools.removeInListModel( uploadingDownloadingFiles, function (x) {return x.name === fileDescriptor.name});


                    Presenter.instance.decrementUploadRunning();

                    var listFiles = result.split("\n");

                    mainView.notifyFile(fileDescriptor.name,0,listFiles.length,"Uploading","StatusAndLength")

                    Tools.forEachInArray(listFiles, function (x) {
                        var fd = documentFolder.createFileDescriptorFromFile(x);
                        Presenter.instance.startUpload(fd,"");

                    });

                    appNotification.logEvent(Zc.AppNotification.Add,"Uploading",fileName,"image://icons/" + "file:///" + fileName)

                    return;
                }
            }

            onFileUploaded :
            {

                Presenter.instance.uploadFinished(fileName,true);

                // close the upload view
                closeUploadViewIfNeeded()
            }

            onFileDownloaded :
            {
                Presenter.instance.downloadFinished(fileName);
                // close the upload view
                closeUploadViewIfNeeded()
            }

        }

        onStarted:
        {
            itemsFileList.loadItems(itemsFileListQueryStatus);
            documentFolder.ensureLocalPathExists();
            documentFolder.ensureLocalPathExists(".upload/");
            documentFolder.ensureLocalPathExists(".download/");

            //        documentFolder.loadRemoteFiles(documentFolderQueryStatus);
        }
    }

    ListModel
    {
        id : listFileModel
    }

    ListModel
    {
        id : uploadingDownloadingFiles
    }


    function joinFile(name,nbrOfFiles)
    {

        var fd = documentFolder.getFileDescriptor(name,true);

        documentFolder.joinLargeFileToLocalFolder(fd, nbrOfFiles, 10 * 1024 * 1024, ".download", "")
    }

    function incrementDownloadStatus(name,number)
    {
        var index = Tools.getIndexInListModel(listFileModel,function(x) {return x.name === name});

        var newValue = number + 1;

        listFileModel.setProperty(index,"downloadPacket",newValue);

        if (newValue >= listFileModel.get(index).totalPacket)
        {
            listFileModel.setProperty(index,"downloadStatus","downloaded");
            joinFile(name,listFileModel.get(index).totalPacket)
        }
    }

    function incrementNbrPacket(name,number)
    {
        var index = Tools.getIndexInListModel(listFileModel,function(x) {return x.name === name});
        var newPacket = number + 1 //listFileModel.get(index).nbrPacket + 1;
        var newStatus = listFileModel.get(index).status;
        var totalPacket = listFileModel.get(index).totalPacket

        if (newPacket >= listFileModel.get(index).totalPacket)
        {
            newStatus = "Uploaded";
            appNotification.logEvent(Zc.AppNotification.Add,"Uploaded",name,"image://icons/" + "file:///" + name)
        }

        notifyFile(name,newPacket,totalPacket,newStatus,"","IncrementNbrPacket")
    }


    function updateListFile(name,val)
    {
        var index = Tools.getIndexInListModel(listFileModel,function(x) {return x.name == name});

        var o = Tools.parseDatas(val);

        if (index === -1 && o.status !== "Deleting")
        {
            listFileModel.append( { "name"  : o.name,
                                     "nbrPacket" : o.nbrPacket,
                                     "totalPacket" : o.totalPacket,
                                     "status" : o.status,
                                     "isSelected" : false,
                                     "downloadStatus" : "",
                                     "downloadPacket" : 0,
                                     "uploader" : o.uploader
                                 });

            if (o.localPath !== undefined  && o.localPath !== "")
            {
                var fd = documentFolder.createFileDescriptorFromFile(o.localPath);

                if (fd === null)
                    return;

                fd.queryProgress = 1;
                Presenter.instance.startUpload(fd.cast,o.localPath);
            }
            listFileModel.setProperty(index,"status",o.status)
        }
        else
        {
            listFileModel.setProperty(index,"nbrPacket",o.nbrPacket)
            listFileModel.setProperty(index,"totalPacket",o.totalPacket)
            listFileModel.setProperty(index,"status",o.status)
        }



        //    console.log(">> try to send nex packet " + o.typeOfModification)
        // Send the next packet
        if (o.typeOfModification === "IncrementNbrPacket")
        {
            Presenter.instance.nextUpload(o.name);
        }
    }


    function closeUploadViewIfNeeded()
    {
        if (uploadingDownloadingFiles.count === 0)
        {
            loaderUploadView.height = 0
        }
    }


    function openUploadView()
    {
        if (loaderUploadView.height === 0)
        {
            loaderUploadView.height = 200
        }
    }


    SplitView
    {
        anchors.fill: parent
        orientation: Qt.Vertical

        Component
        {
            id : handleDelegateVertical

            Rectangle
            {
                height : 10
                color :  styleData.hovered ? "grey" :  "lightgrey"

            }
        }


        handleDelegate : handleDelegateVertical

        Loader
        {
            id : loader

            source : "LargeFileGridView.qml"

            Rectangle
            {
                anchors.fill: parent
                color : "white"
            }

            onSourceChanged:
            {
                item.setModel(listFileModel);
            }

            Layout.fillWidth : true
            Layout.fillHeight : true
        }



        Loader
        {
            id : loaderUploadView
            height : 0

            source : "UploadStatusView.qml"

            onSourceChanged:
            {
                item.setModel(uploadingDownloadingFiles);
            }
        }
    }

    SplashScreen
    {
        id : splashScreenId
        width : parent.width
        height: parent.height
        z: 100
        visible: true
    }


    function notifyFile(name,nbrPacket,totalPacket,status,localPath,typeOfModification)
    {
        var o ={}
        o.name = name;
        o.status = status;
        o.nbrPacket = nbrPacket;
        o.totalPacket = totalPacket;
        o.typeOfModification = typeOfModification;
        o.uploader = mainView.context.nickname;

        if (localPath!== null && localPath!== undefined && localPath!== "")
        {
            o.localPath = localPath.toString();
        }
        else
        {
            o.localPath = ""
        }

        itemsFileList.setItem(name,JSON.stringify(o))
    }


    function putFileOnTheCloud(fileUrl)
    {
        openUploadView()

        var fd = documentFolder.createFileDescriptorFromFile(fileUrl);
        if (fd === null)
            return;

        mainView.notifyFile(fd.name,0,0,"Waiting",fileUrl,"Status");
    }


    FileDialog
    {
        id: fileDialog

        selectFolder: state === "putOnLocalDrive" ? true : false

        onAccepted:
        {
            if ( state === "putOnCloud" )
            {
                putFileOnTheCloud(fileDialog.fileUrl);
            }
        }
    }

    onLoaded :
    {
        activity.start();
    }

    onClosed :
    {
        activity.stop();
    }

    // TODO : effacer les fichiers existants sur le disque et server
    function deleteSelectedFiles()
    {
        var toDeleted = [];

        Tools.forEachInListModel( listFileModel, function(x)
        {
            if (x.isSelected)
            {
                toDeleted.push(x)
            }
        })

        Tools.forEachInArray(toDeleted, function (x) {

            if (x.status === "Deleting")
                return;

            //            var totalPacket = x.totalPacket
            //            console.log(">> NOTIFY FILE FROM to DELETED")
            //            notifyFile(x.name,0 ,x.nbrPacket,"Deleting","")

            for (var i = 0; i < x.totalPacket; i++)
            {
                var fd = documentFolder.getFileDescriptor(x.name + "_" + i ,true)
                documentFolder.deleteFile(fd);
                //    Presenter.instance.startDelete(fd);
            }

            itemsFileList.deleteItem(x.name);

        });


    }

    function downloadFile(itemName)
    {

        var item = Tools.findInListModel(listFileModel, function (x) { return x.name === itemName});


        // Deleting in progress
        if (item.status === "Deleting")
            return;

        // Download in progress
        if (item.downloadStatus === "Downloading")
            return;

        // Not uploaded
        if (item.totalPacket !== item.nbrPacket)
            return;

        // Already Downloaded
        if (item.totalPacket === item.downloadPacket && item.downloadStatus === "downloaded")
            return;

        // Not joined
        if (item.totalPacket === item.downloadPacket)
        {
            joinFile(item.name,item.totalPacket)
            return;
        }

        // download in progress
        openUploadView();

        var totalPacket = item.totalPacket;

        Tools.setPropertyinListModel(listFileModel,"downloadStatus", "Downloading", function (x) { return x.name === itemName})


        for (var i = 0 ; i < totalPacket ; i ++)
        {
            var existingfileDescriptor = documentFolder.createFileDescriptorFromFile(documentFolder.localPath + ".download/" + item.name + "_" + i);

            if (existingfileDescriptor !== null)
            {
                if (i === (totalPacket - 1))
                    continue;
                if (existingfileDescriptor.size === (10 * 1024 * 1024))
                    continue;
            }

            var fileDescriptor = documentFolder.getFileDescriptor(item.name + "_" + i,true);
            fileDescriptor.setRemoteInfo(1024*1024*10,null)
            var completePath = documentFolder.localPath + ".download/";
            Presenter.instance.startDownload(fileDescriptor,completePath);
        }
    }
}
