#define _USE_MATH_DEFINES
#include <holodaye/elevation.h>
#include "math.h"

ElevationData::ElevationData(){
    fake = true;
    resolution = 20;
}

bool ElevationData::isfake(){return fake;}

unsigned int ElevationData::getResolution(){return resolution;}

float ElevationData::get_elevation(int x, int y){
    if(fake){
        double r = sqrt((double)x*x + (double)y*y);
        return r<=39112.82854?abs(x)*(0.5*sin(r/300)+0.5)/10:-1.0; 
    }
    else
        return 0.0;
}
