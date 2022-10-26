#pragma once

class ElevationData{
public:
    // default initialization
    ElevationData();
    // Check whether this is a fake data or a real one.
    bool isfake();
    unsigned int getResolution();
    float get_elevation(int x, int y);
private:
    bool fake;
    int resolution;
};

class ElevationQuery{
public:
    // default initialization
    ElevationQuery(float x, float y, float theta, ElevationData* data);
    void query(float* h, float* d, int length);
private:
    float compute_distance(int x,int y,float dx,float dy);
    int last_x, last_y;
    float theta, origin_x, origin_y, step_size;
    float direction_x, direction_y;
    unsigned int mode, resolution;
    float error;
    bool started;
    ElevationData* data;
};