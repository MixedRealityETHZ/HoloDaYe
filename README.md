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
|```landscape_demo\```|demo to show the elevation data|Matlab|
## Some notes
### Catch2
Here we use Catch2 for unit tests because it is much smaller and neater than google test. About Catch2, please read their [readme](ext/Catch2/README.md) or check their [github](https://github.com/catchorg/Catch2).
### Landscape Demo
Those files under the folder ```landscape_demo``` is for visualizing original/fake elevation map file. The script should be runned with Matlab.

### [ARKit demos](https://github.com/olucurious/Awesome-ARKit)
