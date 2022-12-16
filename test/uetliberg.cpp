#include <holodaye/elevation.h>
#include <holodaye/utils.h>
#include <iostream>

int main(){
    LV95 coord = GPS2LV95(8.491263136328094,47.350187074002775);
    GPS gps = LV952GPS(coord.E,coord.N,0);
    coord = GPS2LV95(gps.lon,gps.lat);
    std::cout<<coord.E<<" "<<coord.N<<std::endl;
    ElevationData data;
    std::cout<<data.get_elevation(coord.E, coord.N)<<std::endl;
}