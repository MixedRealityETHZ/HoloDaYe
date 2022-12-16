#include <holodaye/elevation.h>
#include <holodaye/utils.h>
#include <iostream>

int main(){
    LV95 coord = GPS2LV95(8.491038526435288,47.35020711144787);//wechat
    GPS gps = LV952GPS(coord.E,coord.N);
    coord = GPS2LV95(gps.lon,gps.lat);
    std::cout<<coord.E<<" "<<coord.N<<std::endl;
    ElevationData data;
    std::cout<<data.get_elevation(coord.E, coord.N)<<" "<< LV952GPS(coord.E, coord.N,data.get_elevation(coord.E, coord.N)).alt<<std::endl;
}