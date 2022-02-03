#!/bin/sh

rm -rf Podfile.lock
rm -rf Pods
rm -rf ~/Library/Developer/Xcode/DerivedData
pod cache clean --all
pod install