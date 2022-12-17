#pragma once

class ElevationData{
public:
    // default initialization
    ElevationData();
    ElevationData(char* filename);
    // default destructor
    ~ElevationData();
    // Check whether this is a fake data or a real one.
    bool isfake();
    unsigned int getResolution();
    float get_elevation(int x, int y);
    int get_origin_x();
    int get_origin_y();
private:
    bool fake;
    int resolution;
    int origin_x, origin_y;
    int len_x, len_y;
    int min_x, max_x, min_y, max_y;
    int scale;
    int block_side_length, block_size, block_length;
    int* index_mat;
    unsigned short int** zipped;
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
    int dataset_x,dataset_y;
    ElevationData* data;
};