#define _USE_MATH_DEFINES
#include "holodaye/elevation.h"
#include "holodaye/output.h"
#define _USE_MATH_DEFINES
#include <math.h>
#include <vector>
#include <iostream>
ElevationAngle::ElevationAngle(int length, float x, float y, ElevationData* data): length_(length), x_(x), y_(y), ElevData_(data) {
    border_h_ = new float[360];  // record the height with maximum slope in 360 directions
    border_d_ = new float[360];  // record the height with maximum slope in 360 directions
    max_slope_ = new float[360]; // record the maximum slope in 360 directions
    // cur_z_ = z; 
};

void ElevationAngle::FindPeakInCircle(){
    float cur_angle = 0;
    for (int i = 0; i < 360; i++){
        cur_angle += M_PI/180;
        GetMaxSlope(cur_angle, i);
    }

}

inline float ElevationAngle::CalAngle(float h, float d) {
    return (h - cur_z_) / d;
};

// Get a list of elevation angles with the given length
void ElevationAngle::GetMaxSlope(float angle, int index) {                  
    // create arrays with the given length to store queries
    float *h = new float[length_];
    float *d = new float[length_]; 

    float max_slope = -1e4;
    bool is_continue = true;   
    ElevationQuery elev_query(x_, y_, angle, ElevData_);     
    elev_query.query(h, d, 1); // query #data = length_
    cur_z_ = h[0];
    std::cout<< "h[0]: " << h[0] <<std::endl;

    float max_border_h = 0;
    float max_border_d = 0;
    while (is_continue) {
        elev_query.query(h, d, length_); // query #data = length_

        for (int i = 0; i < length_; i++) {
            if (h[i] >= 0) {
                float angle = CalAngle(h[i], d[i]);
                if (angle > max_slope) {
                    max_slope  = angle;
                    max_border_h = h[i];
                    max_border_d = d[i];
                }
            } else {
                // If query position is outside Switzerland, then stop
                is_continue = false;
                break;
            }
        }
        // If the current max slope times distance is larger than the maximum peak in switzerland, then stop searching
        if (max_slope * d[length_-1] + cur_z_> MAX_HEIGHT) {
            is_continue = false;
        }      
    }

    
    max_slope_[index] = max_slope;
    border_h_[index] = max_border_h;
    border_d_[index] = max_border_d;

    delete[] h, d;
};

