# HoloDaYe
Inspired by the project nori2 from the lecture computer graphics, I decide to use cmake to build this project, since cmake has a good cross-platform performance and is easy to maintain. For unit tests, Catch2 is used here.
## Coding conventions
- No strict rules for the format of the code text.
- Seperate declaration and definitions into header files and cpp files respectively.
- Before submitting pull requests, you should write unit tests for your code and make sure that the code could work as you expected. In such manner the effort to debug could be minimized for everyone.
## File Structure

|File/Folder Name|Usage|Notice|
|---|---|---|
|```CMakeLists.txt```|cmake control file||
|```src\```|source code|   |
|```ext\```|external libraries|   |
|```include\```|header files and other internal libraries|   |
|```test\```|unit test files||
|```build\```|all things built|Not Tracked|
|```data\```|scripts to generate data set|Limited Tracked|
|```landscape_demo\```|demo to show the elevation data|Matlab|

## Demonstration
you can download some demonstrations of the project with the following link:
https://drive.google.com/file/d/1SR0iJv06M0FsZnBvHHSCBlNEyIDEVwKG/view?usp=share_link

## Before running
### About data set
Since this repository contains no data, you need to first download the preprocessed data set from [google drive](https://drive.google.com/file/d/1VEH-fl9MNWkXczAR74fiCL-5GnzCDdr6/view?usp=sharing)(recommended) into ```data\``` or to preprocess the data set from scratch according to the description in ```data\readme.md```
## Some notes
### Catch2
Here we use Catch2 for unit tests because it is much smaller and neater than google test. About Catch2, please read their [readme](ext/Catch2/README.md) or check their [github](https://github.com/catchorg/Catch2).
### Landscape Demo
Those files under the folder ```landscape_demo``` is for visualizing original/fake elevation map file. The script should be runned with Matlab.
### Sytem requirement
Our server is built on the Windows 11/10 and client is on the MacOS. The change of operating system is currently not allowed

## Check List (before running the code)
- We use cmake to compile the code, please make sure you have the compiler with required version on your local machine before running the code
- Make sure the client and server are connected to the same network.
- Make sure the client and server share the same ip address and port number (check ```scr\main.cpp for server ``` and [`SettingsViewController.swift`](https://github.com/MixedRealityETHZ/HoloDaYe/blob/6d962f94a84856e59d2e725d7c28fba08288bfc6/ARKit-CoreLocation/ARKit%2BCoreLocation/SettingsViewController.swift#L42) for client)
- If you want to use the north calibration, please let the mobile devie roughly facing the north direction before you launch the app.

## Running the code
### How to start the server
```
cd HoloDaYe 
mkdir build
cd build
cmake ..
make
```
You will find the file in name of holodaye.exe when you compile the code successfully
Start the exe file and it will automatically open a terminal (start of the server)

### How to build the application (client)

**Citation**: Our app is developed on the codebase of [ARKit-Corelocation](https://github.com/ProjectDent/ARKit-CoreLocation)

Please build our app using Xcode on an apple device with IOS 16 or upwards.
Our app has been tested on iPhone 12  and iPad pro-2021 with IOS 16.1.

Please remember to sign the app with an apple developer account before building.

#### Steps

##### Setting up dependencies using CocoaPods:

1. add to the podfile: 

```
pod 'ARCL'
pod 'SwiftSocket'
```

2. In Terminal, navigate to the project folder, then:

```
pod update
pod install
```

##### Open the project file `Elevation.xcworkspace` with Xcode

1. make sure your server and your app are under the same LAN and modify the IP address in the file [`SettingsViewController.swift`](https://github.com/MixedRealityETHZ/HoloDaYe/blob/6d962f94a84856e59d2e725d7c28fba08288bfc6/ARKit-CoreLocation/ARKit%2BCoreLocation/SettingsViewController.swift#L42)

2. build the app on your device with Xcode

