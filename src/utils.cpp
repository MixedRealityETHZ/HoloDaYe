#define _USE_MATH_DEFINES
#include "holodaye/utils.h"
#define SQUARE(x) ((x)*(x))
#define TRIPPLE(x) ((x)*(x)*(x))
#include <cmath>
#define ROUND_2_INT(f) ((int)(f >= 0.0 ? (f + 0.5) : (f - 0.5)))
#include <stdio.h>
#include <iostream>
#include <list>
#include <iterator>
using namespace std;

Struct1 LV952GPS(int E, int N){return LV952GPS(E,N,0);}
Struct1 LV952GPS(int E, int N, double H) {
    Struct1 gps;
    double E_ = ((double)E - 2600000) / 1000000;
    double N_ = ((double)N - 1200000) / 1000000;
    
    gps.lon = 2.6779094 + 4.728982 * E_ + 0.791484 * (E_ * N_) + 0.1306 * (E_ * SQUARE(N_)) - 0.0436 * (TRIPPLE(E_));
    gps.lat = 16.9023892 + 3.238272 * N_ - 0.270978 * (SQUARE(E_)) - 0.002528 * (SQUARE(N_)) - 0.0447 * (SQUARE(E_) * N_) - 0.0140 * (TRIPPLE(N_));
    
    gps.alt = H + 49.55 - 12.60 * E_ - 22.64 * N_;
    
    gps.lon = gps.lon * 100 /36;
    gps.lat = gps.lat * 100 /36;
    return gps;
    }

Struct2 GPS2LV95(double lon, double lat) {return GPS2LV95(lon, lat, 0);}

Struct2 GPS2LV95(double lon, double lat, double alt) {
    
    Struct2 lv95;
    // unit is second
    double lat_ = (lat * 3600 - 169028.66) / 10000;
    double lon_ = (lon * 3600 - 26782.5) / 10000;

    double E_ = 2600072.37 + 211455.93 * lon_ - 10938.51 * (lon_ * lat_) - 0.36 * (SQUARE(lat_) * lon_) - 44.54 * (TRIPPLE(lon_));
    double N_ = 1200147.07 + 308807.95 * lat_ + 3745.25 * SQUARE(lon_) + 76.63 * (SQUARE(lat_)) - 194.56 * (SQUARE(lon_) * lat_) + 119.79 * (TRIPPLE(lat_));
    
    // lv95.H = alt - 49.55 + 2.73 * lon_ + 6.94 * lat_;
    lv95.H = alt;

    lv95.E = ROUND_2_INT(E_);
    lv95.N = ROUND_2_INT(N_);
   
   return lv95;
}


void printNestedList(list<list<double> > nested_list)
{
    cout << "[\n";
 
    // nested_list`s iterator(same type as nested_list)
    // to iterate the nested_list
    list<list<double> >::iterator nested_list_itr;
 
    // Print the nested_list
    for (nested_list_itr = nested_list.begin();
        nested_list_itr != nested_list.end();
        ++nested_list_itr) {
 
        cout << " [";
 
        // normal_list`s iterator(same type as temp_list)
        // to iterate the normal_list
        list<double>::iterator single_list_itr;
 
        // pointer of each list one by one in nested list
        // as loop goes on
        list<double>& single_list_pointer = *nested_list_itr;
 
        for (single_list_itr = single_list_pointer.begin();
            single_list_itr != single_list_pointer.end();
            single_list_itr++) {
            cout << " " << *single_list_itr << " ";
        }
        cout << "]\n";
    }
    cout << "]";
}
