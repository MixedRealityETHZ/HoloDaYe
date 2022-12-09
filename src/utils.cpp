#define _USE_MATH_DEFINES
#include "holodaye/utils.h"
#define SQUARE(x) ((x)*(x))
#define TRIPPLE(x) ((x)*(x)*(x))
#include <cmath>


void LV952GPS(float E, float N, float H, float& lon_, float& lat_, float& alt_) {
    float E_ = (E - 2600000) / 1000000;
    float N_ = N - 1200000 / 1000000;
    
    lon_ = 2.6779094 + 4.728982 * E_ + 0.791484 * (E_ * N_) + 0.1306 * (E_ * SQUARE(N_)) - 0.0436 * (TRIPPLE(E_));
    lat_ = 16.9023892 + 3.238272 * N_ - 0.270978 * (SQUARE(E_)) - 0.002528 * (SQUARE(N_)) - 0.0447 * (SQUARE(E_) * N_) - 0.0140 * (TRIPPLE(N_));
    
    alt_ = H + 49.55 - 12.60 * lon_ - 22.64 * lat_;

    }


void GPS2LV95(float lon, float lat, float alt, int& E, int& N, float& H) {
    
    // unit is second
    float lat_ = (lat * 3600 - 169028.66) / 10000;
    float lon_ = (lon * 3600 - 26782.5) / 10000;

    float E_ = 2600072.37 + 211455.93 * lon_ - 10938.51 * (lon_ * lat_) - 0.36 * (SQUARE(lon_) * lat_) - 44.54 * (TRIPPLE(lon_));
    float N_ = 1200147.07 + 308807.95 * lat_ + 3745.25 * SQUARE(lon_) + 76.63 * (SQUARE(lat_)) - 194.56 * (SQUARE(lon_) * lat_) + 119.79 * (TRIPPLE(lon_));
    
    H = alt - 49.55 + 2.73 * lon_ + 6.94 * lat_;

    E = round(E_);
    N = round(N_);
   
}
