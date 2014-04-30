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

FileTextDelegate
{
    text : "<a href=\" \">"+name+"</a>"
//        isBusy : item != null && item !== undefined ?  item.busy : false
    position : index

    onClicked :
    {
        mainView.downloadFile(name)
    }

    notifyPressed: true

    Rectangle
    {
        anchors.top : parent.top
        anchors.bottom : parent.bottom
        anchors.left    : parent.left
        opacity : 0.5
        visible : item.queryProgress > 0
        color   : "green"

        width  : parent.width * item.queryProgress / 100
    }
}

