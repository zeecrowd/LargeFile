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

import QtQuick 2.0
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
            id: exportAction
            shortcut: "Ctrl+E"
            iconSource: "qrc:/LargeFile/Resources/import.png"
            tooltip : "Download pictures"
            onTriggered:
            {
                mainView.state = "putOnLocalDrive"
                fileDialog.selectMultiple = false;
                fileDialog.nameFilters = ""
                fileDialog.selectFolder = true
                fileDialog.open()
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

                    splashScreenId.height = 0;
                    splashScreenId.width = 0;
                    splashScreenId.visible = false;


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

                    console.log(">> downloadedFiles.length " + downloadedFiles.length )
                    console.log(">> downloadedFilesProgress.length " + downloadedFilesProgress.length )

                    Tools.forEachInListModel(listFileModel,function (x)
                    {

                        if (Tools.findInArray(downloadedFiles,function (y) {return y === x.name}) !== null)
                        {
                            Tools.setPropertyinListModel(listFileModel,"downloadStatus",x.totalPacket,function (y){ return y === x.name});
                        }
                        else
                        {
                            var progressfileCount = Tools.countInArray(downloadedFilesProgress,function (y) {return y.indexOf(x.name) !== -1});

                            if ( progressfileCount > 0)
                            {
                                console.log(">> try to seproperty downloadStatus " + x.name)
                                Tools.setPropertyinListModel(listFileModel,"downloadStatus",progressfileCount,function (z)
                                {
                                    return z.name === x.name
                                }
                                );
                            }
                        }
                    });

                }

                onErrorOccured :
                {
                    console.log(">> ERRROR " + error + " " + errorCause  + " " + errorMessage)
                }
            }

            onItemChanged :
            {
                console.log(">> ONE ITEM CHANGED")
                mainView.updateListFile(idItem,getItem(idItem,""))
            }

            onItemDeleted :
            {
                console.log(">> try to delete " + idItem)
                Tools.removeInListModel(listFileModel, function (y) {return y.name === idItem })
            }
        }

        Zc.CrowdDocumentFolder
        {
            id   : documentFolder
            name : "LargeFileDocumentFolder"
            
            //            Zc.QueryStatus
            //            {
            //                id : documentFolderQueryStatus

            //                onErrorOccured :
            //                {
            //                    console.log(">> ERRROR OCCURED")
            //                }

            //                onCompleted :
            //                {
            //                    loader.item.setModel(documentFolder.files);
            //                    splashScreenId.height = 0;
            //                    splashScreenId.width = 0;
            //                    splashScreenId.visible = false;
            //                }
            //            }

            onImportFileToLocalFolderCompleted :
            {

                console.log(">> onImportFileToLocalFolderCompleted " + localFilePath)
                // import a file to the .upload directory finished
                if (localFilePath.indexOf(".upload") !== -1)
                {
                    var fileDescriptor = Presenter.instance.fileDescriptorToUpload[fileName];
                    Presenter.instance.fileDescriptorToUpload[fileName] = null;

                    Tools.removeInListModel( uploadingDownloadingFiles, function (x) {return x.name === fileDescriptor.name});


                    //                    Tools.setPropertyinListModel(uploadingDownloadingFiles,"status","Uploading",function (x) { return x.name === fileName });
                    Presenter.instance.decrementUploadRunning();

                    var listFiles = result.split("\n");

                    mainView.notifyFile(fileDescriptor.name,0,listFiles.length,"Uploading")

                    Tools.forEachInArray(listFiles, function (x) {
                        var fd = documentFolder.createFileDescriptorFromFile(x);
                        Presenter.instance.startUpload(fd,"");

                    });

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

            //            onFileDeleted :
            //            {
            //                notifySender.sendMessage("","{ \"sender\" : \"" + mainView.context.nickname + "\", \"action\" : \"deleted\" , \"fileName\" : \"" + fileName + "\"}");
            //            }
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


    function joinFileIndex()
    {

    }

    function incrementDownloadStatus(name)
    {
        var index = Tools.getIndexInListModel(listFileModel,function(x) {return x.name === name});
        var newValue = listFileModel.get(index).downloadStatus + 1;

        listFileModel.setProperty(index,"downloadStatus",newValue);


        if (newValue >= listFileModel.get(index).totalPacket)
        {
            joinFile(index)
        }

    }

    function incrementNbrPacket(name)
    {
        var index = Tools.getIndexInListModel(listFileModel,function(x) {return x.name == name});
        var newPacket = listFileModel.get(index).nbrPacket + 1;
        var newStatus = listFileModel.get(index).status;
        if (listFileModel.get(index).totalPacket === newPacket)
        {
            newStatus = ""
        }
    }


    function updateListFile(name,val)
    {
        var index = Tools.getIndexInListModel(listFileModel,function(x) {return x.name == name});

        var o = Tools.parseDatas(val);

        if (index === -1)
        {
            listFileModel.append( { "name"  : o.name,
                                     "nbrPacket" : o.nbrPacket,
                                     "totalPacket" : o.totalPacket,
                                     "status" : o.status,
                                     "isSelected" : false,
                                     "downloadStatus" : 0
                                 });

            if (o.localPath !== undefined  && o.localPath !== "")
            {
                var fd = documentFolder.createFileDescriptorFromFile(o.localPath);

                if (fd === null)
                    return;

                fd.queryProgress = 1;
                Presenter.instance.startUpload(fd.cast,o.localPath);
            }
        }
        else
        {
            listFileModel.setProperty(index,"nbrPacket",o.nbrPacket)
            listFileModel.setProperty(index,"totalPacket",o.totalPacket)
            listFileModel.setProperty(index,"status",o.status)
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
    }


    function notifyFile(name,nbrPacket,totalPacket,status,localPath)
    {
        var o ={}
        o.name = name;
        o.status = status;
        o.nbrPacket = nbrPacket;
        o.totalPacket = totalPacket;
        if (localPath!== null && localPath!== undefined && localPath!== "")
        {
            o.localPath = localPath.toString();
        }
        else
        {
            o.localPath = ""
        }


        console.log(">> itemsFileList.setItem " + name)
        console.log(">> itemsFileList.setItem " + JSON.stringify(o))

        itemsFileList.setItem(name,JSON.stringify(o))
    }


    function putFileOnTheCloud(fileUrl)
    {
        openUploadView()

        var fd = documentFolder.createFileDescriptorFromFile(fileUrl);
        if (fd === null)
            return;

        mainView.notifyFile(fd.name,0,0,"Waiting",fileUrl);
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

    function importFile(fileUrls)
    {
        //        var fds = [];
        //        for ( var i = 0 ; i < fileUrls.length ; i ++)
        //        {
        //            var fd = documentFolder.addFileDescriptorFromFile(fileUrls[i]);
        //            if (fd !== null)
        //            {
        //                var fdo = {}
        //                fdo.fileDescriptor =fd;
        //                fdo.url = fileUrls[i];
        //                fds.push(fdo);
        //                fd.queryProgress = 1;
        //            }
        //        }

        //        Tools.forEachInArray(fds, function (x)
        //        {
        //            Presenter.instance.startUpload(x.fileDescriptor,x.url);
        //        });
    }

    function exportFile()
    {
        //        Tools.forEachInObjectList( documentFolder.files, function(x)
        //        {
        //            if (x.cast.isSelected)
        //            {
        //                if (x.cast.status !== "")
        //                {
        //                    x.queryProgress = 1;
        //                    Presenter.instance.startDownload(x.cast);
        //                    //documentFolder.downloadFile(x.cast)
        //                }
        //            }
        //        })
    }

    // TODO : effacer les fichiers existants sur le disque
    function deleteSelectedFiles()
    {
        var toDeleted = [];

        Tools.forEachInListModel( listFileModel, function(x)
        {
            if (x.isSelected)
            {
                toDeleted.push(x.name)
            }
        })


        Tools.forEachInArray(toDeleted, function (x) {
            itemsFileList.deleteItem(x)
        });
    }

    function downloadFile(itemName)
    {
        openUploadView();


        var item = Tools.findInListModel(listFileModel, function (x) { return x.name === itemName});

        var totalPacket = item.totalPacket;

        for (var i = 0 ; i < totalPacket ; i ++)
        {

            var existingfileDescriptor = documentFolder.createFileDescriptorFromFile(documentFolder.localPath + ".download/" + item.name + "_" + i);

            console.log(">> existingfileDescriptor " + existingfileDescriptor  + " --> " + i)

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
