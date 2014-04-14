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

Qt.include("Tools.js")

var instance = {}

instance.fileStatus = {}

instance.fileDescriptorToUpload = {};
instance.fileDescriptorToDownload = {};
//instance.fileDescriptorToDelete = {};

var maxNbrDomwnload = 1;
var maxNbrUpload = 1;
//var maxNbrDelete = 1;

var uploadRunning = 0;
var downloadRunning = 0;
//var deleteRunning = 0;

var filesToDownload = []
var filesToUpload = []
//var filesToDelete = []


//instance.nextDelete = function()
//{

//    if (filesToDelete.length > 0)
//    {
//        instance.incrementDeleteRunning()

//        var file = filesToDelete.pop();

//        documentFolder.deleteFile(file.cast)
//    }
//}

function nextDownload()
{

    if (filesToDownload.length > 0)
    {
        instance.incrementDownloadRunning()

        var file = filesToDownload.pop();
        setPropertyinListModel(uploadingDownloadingFiles,"status","Downloading",
                               function (x) {
                                   return x.name === file.descriptor.name }
                               );


        documentFolder.downloadFileTo(file.descriptor.cast,file.path)
    }
}

function nextUpload()
{
    if (filesToUpload.length > 0)
    {
        instance.incrementUploadRunning();

        var file = filesToUpload.pop();


        if (file.path !== "" && file.path !== null && file.path !== undefined)
        {

            mainView.notifyFile(file.descriptor.name,0,0,"Splitting","")
            documentFolder.importLargeFileToLocalFolder(file.descriptor,file.path,1024*1024*10,".upload")
        }
        else
        {
            setPropertyinListModel(uploadingDownloadingFiles,"status","Uploading",function (x) { return x.name === file.descriptor.name });
            documentFolder.uploadFile(file.descriptor,".upload/" + file.descriptor.name)
        }
    }
}

//instance.incrementDeleteRunning = function()
//{
//    deleteRunning = deleteRunning + 1
//}

//instance.decrementDeleteRunning = function()
//{
//    deleteRunning = deleteRunning - 1
//}


instance.incrementUploadRunning = function()
{
    uploadRunning = uploadRunning + 1
}

instance.decrementUploadRunning = function()
{
    uploadRunning = uploadRunning - 1
}

instance.incrementDownloadRunning = function()
{
    downloadRunning = downloadRunning + 1
}

instance.decrementDownloadRunning = function()
{
    downloadRunning = downloadRunning - 1
}

//instance.startDelete = function(fd)
//{
//    filesToDelete.push(fd)

//    /*
//    */
//    if ( instance.fileDescriptorToDelete[fd.name] === null || instance.fileDescriptorToDelete[fd.name] === undefined)
//    {
//        instance.fileDescriptorToDelete[fd.name] = fd
//  //      fd.queryProgressChanged.connect(function(x){ deleteQueryProgress(fd.queryProgess,fd.name) });
//    }

//    if (deleteRunning < maxNbrDelete)
//    {
//        instance.nextDelete();
//    }
//}


instance.startDownload = function(file,path)
{
    var fd = {}
    fd.descriptor = file;
    fd.path = path

    filesToDownload.push(fd)

    /*
    ** uploadingFiles contain all progress ulpoading files
    */
    if ( instance.fileDescriptorToDownload[file.name] === null || instance.fileDescriptorToDownload[file.name] === undefined)
    {
        instance.fileDescriptorToDownload[file.name] = file

        /*
        ** to now the state of the progress
        */


        file.queryProgressChanged.connect(function(x){ updateQueryProgress(file.queryProgress,file.name) });
    }


    var found = findInListModel(uploadingDownloadingFiles, function(x) {return x.name === file.name} )

    if (found === null)
    {
        uploadingDownloadingFiles.append( { "name"  : file.name,
                                 "action" : "Download",
                                 "progress" : 0,
                                 "status" : "Waiting",
                                 "message" : "",
                                 "localPath" : path,
                                  "validated" : false
                          })
    }

    if (downloadRunning < maxNbrDomwnload)
    {
        nextDownload();
    }
}


instance.startUpload = function(file,path,baseFileName)
{
    var fd = {}
    fd.descriptor = file;
    fd.path = path
    fd.baseFileName = baseFileName

    filesToUpload.push(fd)

    /*
    ** uploadingFiles contain all progress ulpoading files
    */
    if ( instance.fileDescriptorToUpload[file.name] === null || instance.fileDescriptorToUpload[file.name] === undefined)
    {
        instance.fileDescriptorToUpload[file.name] = file

        /*
        ** to now the state of the progress
        */
        file.queryProgressChanged.connect(function(){ updateQueryProgress(file.queryProgress,file.name) });
    }

    var found = findInListModel(uploadingDownloadingFiles, function(x) {return x.name === file.name} )

    if (found === null)
    {
        uploadingDownloadingFiles.append( { "name"  : file.name,
                                 "action" : "Upload",
                                 "progress" : 0,
                                 "status" : "Waiting",
                                 "message" : "",
                                 "localPath" : path,
                                  "validated" : false
                          })
    }
    else
    {
        setPropertyinListModel(uploadingDownloadingFiles,"localPath",path,function (x) { return x.name === file.name });

        // TO DO : check override filename
    }

    if (uploadRunning < maxNbrUpload)
    {
        nextUpload();
    }
}

//function deleteQueryProgress(sender)
//{
//    localQuery.statusChanged.disconnect(deleteQueryProgress)

//    // tout s'est bien passé ok
//    if (localQuery.isCompleted() && localQuery.success("200") || localQuery.success("201"))
//        return;

//    console.log(">> deleteQueryProgress error " + localQuery.name)

//    // prochain delete
//    instance.deleteFinished(localQuery.cast.name,true);
//}

function updateQueryProgress(progress, fileName)
{

    setPropertyinListModel(uploadingDownloadingFiles,"progress",progress,function (x) { return x.name === fileName });
}

//instance.deleteFinished = function(fileName,notify)
//{
//    var fileDescriptor = instance.fileDescriptorToDelete[fileName];

//    if (fileDescriptor !== null && fileDescriptor !== undefined)
//    {
//        documentFolder.removeLocalFile(".upload\\" + fileDescriptor.name)
//        documentFolder.removeLocalFile(".download\\" + fileDescriptor.name)

//        var lastIndex = fileDescriptor.name.lastIndexOf("_");
//        var originFileName = fileDescriptor.name.substring(0,lastIndex);


//        mainView.incrementNbrPacket(originFileName);

//    }
//    instance.fileDescriptorToDownload[fileName] = null
//    instance.decrementDeleteRunning();
////    nextDelete();
//}


/*
** Upload is finished
** clean all object and try to do an next upload
*/


instance.uploadFinished = function(fileName,notify)
{
    var fileDescriptor = instance.fileDescriptorToUpload[fileName];

    if (fileDescriptor !== null && fileDescriptor !== undefined)
    {
        documentFolder.removeLocalFile(".upload\\" + fileDescriptor.name)

        var lastIndex = fileDescriptor.name.lastIndexOf("_");
        var originFileName = fileDescriptor.name.substring(0,lastIndex);

        mainView.incrementNbrPacket(originFileName);

    }
    instance.fileDescriptorToUpload[fileName] = null
    removeInListModel(uploadingDownloadingFiles,function (x) { return x.name === fileName} );
    instance.decrementUploadRunning();
    nextUpload();
}

instance.downloadFinished = function(fileName)
{
    var fileDescriptor = instance.fileDescriptorToDownload[fileName];

    if (fileDescriptor !== null && fileDescriptor !== undefined)
    {
        var lastIndex = fileDescriptor.name.lastIndexOf("_");
        var originFileName = fileDescriptor.name.substring(0,lastIndex);

        mainView.incrementDownloadStatus(originFileName);
    }


    instance.fileDescriptorToDownload[fileName] = null
    removeInListModel(uploadingDownloadingFiles,function (x) { return x.name === fileName} );
    instance.decrementDownloadRunning();
    nextDownload();
}

