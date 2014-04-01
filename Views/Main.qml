/*
** Copyright (c) 2014, Jabber Bees
** All rights reserved.
**
** Redistribution and use in source and binary forms, with or without modification,
** are permitted provided that the following conditions are met:
**
** 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
**
** 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
** in the documentation and/or other materials provided with the distribution.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
** INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
** IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
** HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
** ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
            persistent : false

            Zc.QueryStatus
            {
                id : itemsFileListQueryStatus

                onCompleted :
                {
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
                console.log(">> ONE ITEM CHANGED")
                mainView.updateListFile(idItem,getItem(idItem,""))
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

            //            onFileDownloaded :
            //            {
            //                Presenter.instance.downloadFinished(fileName);
            //                // close the upload view
            //                closeUploadViewIfNeeded()
            //            }

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


    function updateListFile(name,val)
    {
        console.log(">> updateListFile name " + name)
        var index = Tools.getIndexInListModel(listFileModel,function(x) {return x.name = name});

        console.log(">> updateListFile index " + index)
        console.log(">> updateListFile val " + val)

        var o = Tools.parseDatas(val);

        if (index === -1)
        {
            console.log(">> listFileModel.append " + o)
            console.log(">> listFileModel.append o.name" + o.name)

            listFileModel.append( { "name"  : o.name,
                                     "nbrPacket" : o.nbrPacket,
                                     "totalPacket" : o.nbrPacket,
                                     "status" : o.status
                                 });

            console.log(">> o.localPath " + o.localPath)

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
        o.localPath = localPath.toString();

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

    function putFilesOnLocalDrive(folder)
    {
        openUploadView()

        //        Tools.forEachInObjectList( documentFolder.files, function(x)
        //        {
        //            if (x.cast.isSelected)
        //            {
        //                 Presenter.instance.startDownload(x.cast,folder);
        //            }
        //        })

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
            else if (state === "putOnLocalDrive")
            {
                putFilesOnLocalDrive(fileDialog.folder);
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

    function deleteSelectedFiles()
    {
        //        Tools.forEachInObjectList( documentFolder.files, function(file)
        //        {
        //            if (file.cast.isSelected)
        //            {
        //                documentFolder.deleteFile(file);
        //            }
        //        })
    }
}
