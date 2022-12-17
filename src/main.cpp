// Main function, although empty now
#include <iostream>
#include <holodaye/elevation.h>
#define _USE_MATH_DEFINES
#include "holodaye/output.h"
#include <math.h>
#include "holodaye/utils.h"

int main(int argc, char **argv){
	
	int x = 2683691;
	int y = 1247833;
	double z = 553.272;
	cout << z << endl;
	int length = 100;
	cout<< "Reading Data" << endl;
	ElevationData* data = new ElevationData();
	cout<< "Finish reading" << endl;		
	ElevationAngle eleAngle(length, x, y, z, data);
	eleAngle.FindPeakInCircle();
    std::cout<<"Hello World!"<<std::endl;
    return 0;
}