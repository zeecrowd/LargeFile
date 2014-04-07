@echo off

set NAME=LargeFile
set RCC= C:\Qt\Qt5.2.0\5.2.0\msvc2010\bin\rcc.exe
set SRC=..\
set OUTPUT=..\Deploy

IF NOT EXIST %OUTPUT%\. md %OUTPUT%

copy %SRC%\%NAME%.cfg %OUTPUT%
%RCC% -threshold 70 -binary -o %OUTPUT%\%NAME%.rcc %SRC%\%NAME%.Debug.generated.qrc