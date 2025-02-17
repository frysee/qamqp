#!/bin/sh

if [ "$QT_SELECT" = "qt4" ]; then
    sudo apt-get update
    sudo apt-get install libqt4-dev
else
    sudo add-apt-repository -y ppa:canonical-qt6-edgers/ubuntu1204-qt6
    sudo apt-get update
    sudo apt-get install qtbase5-dev
fi