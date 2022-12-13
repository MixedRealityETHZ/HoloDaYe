#pragma once
#include "holodaye/elevation.h"

const float MAX_HEIGHT = 5000; // max elevation in Swizerland

class ElevationAngle{
public:
    ElevationAngle(int length, float x, float y, ElevationData* data);
    ~ElevationAngle() {delete[] border_h_, border_d_, max_slope_;};
    // Fill border_h_, border_d_, and max_slope_ every 1 degree from (angle - PI/2) to (angle + PI/2)
    void FindPeakInCircle();
    void GetMaxSlope(float angle, int index);
private:
    inline float CalAngle(float h, float d);
    // Get the maximal slope, the height and distance from the query position in a certain direction (angle)
    
public:
    float* border_h_;  // record the height with maximum slope in 360 directions
    float* border_d_;  // record the height with maximum slope in 360 directions
    float* max_slope_; // record the maximum slope in 360 directions
private:
    int length_;    // #points to query
    float x_;       // x-cord for current position
    float y_;       // y-cord for current position
    ElevationData* ElevData_;      // switzerland map data
    float cur_z_;
};
