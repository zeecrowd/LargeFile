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

Rectangle
{
    id : fileTextDelegate

    height : 40
    width : parent.width

    signal clicked()

    property bool notifyPressed : false
    property bool isBusy : false
    property int position : 0

//    color : isBusy ? "lightgrey" : /*(position % 2 ? "#FFF2B7" :*/ "white" //)
    property alias text : delegateId.text

//    onIsBusyChanged:
//    {
//        color = isBusy ? "lightgrey" : /*(position % 2 ? "#FFF2B7" :*/ "white" //);
//    }

    Text
    {
        id                          : delegateId
        color                       : "black"
        anchors.verticalCenter      : parent.verticalCenter
        anchors.left                : parent.left
        anchors.leftMargin          : 5
        font.pixelSize              : 16
        textFormat: Text.RichText

        onLinkActivated:
        {
//            if (!isBusy)
//                fileTextDelegate.clicked()
        }
     }
 }

