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
- Make sure the client and server are connected to the same network
- Make sure the client and server share the same ip address and port number
- If you want to use the north calibration, please let the mobile devie roughly facing the north direction during computation.

## Running the code
### How to start the server
''' 
cd HoloDaYe 
mkdir build
cd build
cmake ..
''' 
You will find the file in name of holodaye.exe when you compile the code successfully
Start the exe file and it will automatically open the terminal (start of the server)

### How to start the client

