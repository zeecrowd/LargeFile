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
.pragma library

function forEachInObjectList(objectList, delegate)
{
    for (var i=0;i<objectList.count;i++)
    {
        delegate(objectList.at(i));
    }
}

function forEachInListModel(objectList, delegate)
{
    for (var i=0;i<objectList.count;i++)
    {
        delegate(objectList.get(i));
    }
}

function forEachInArray(array, delegate)
{
    for (var i=0;i<array.length;i++)
    {
        delegate(array[i]);
    }
}


function findInListModel(listModel, findDelegate)
{
    for (var i=0;i<listModel.count;i++)
    {
        if ( findDelegate(listModel.get(i)) )
            return listModel.get(i);
    }

    return null;
}

function findInArray(array, findDelegate)
{
    for (var i=0;i<array.length;i++)
    {
        if ( findDelegate(array[i]) )
            return array[i];
    }

    return null;
}

function countInArray(array, findDelegate)
{
    var result = 0;
    for (var i=0;i<array.length;i++)
    {
        if ( findDelegate(array[i]) )
            result++;
    }

    return result;
}


function findInListModel(listModel, findDelegate)
{
    for (var i=0;i<listModel.count;i++)
    {
        if ( findDelegate(listModel.get(i)) )
            return listModel.get(i);
    }

    return null;
}

function getIndexInListModel(listModel, findDelegate)
{
    for (var i=0;i<listModel.count;i++)
    {
        if ( findDelegate(listModel.get(i)) )
            return i;
    }
    return -1;
}

function removeInListModel(listModel, findDelegate)
{
    var index = getIndexInListModel(listModel, findDelegate);
    if (index === -1)
        return
    listModel.remove(index)
}





function setPropertyinListModel(listModel, prop , value,  findDelegate)
{
    var index = getIndexInListModel(listModel, findDelegate);
    if (index === -1)
        return
    listModel.setProperty(index,prop,value)
}


function parseDatas(datas)
{
    if (datas === null || datas === undefined)
        return {}


    var objectDatas = null;

    try
    {

        objectDatas = JSON.parse(datas);
    }
    catch (e)
    {
        objectDatas = {}
    }

    if (objectDatas === null)
        return {};

    if (objectDatas === undefined)
        return {};

    objectDatas.testparse = "testparse"
    if (objectDatas.testparse !== "testparse")
    {
        return {}
    }

    objectDatas.testparse = undefined;

    return objectDatas;
}
