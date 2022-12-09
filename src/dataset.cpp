#define _USE_MATH_DEFINES
#include <iostream>
#include "memory.h"
#include "math.h"
#include <holodaye/elevation.h>

ElevationData::ElevationData(){
    FILE* file;
    file = fopen("../../data/zipped.dat", "rb");
    // Here, I need to mention the format of the zipped file again
    // Bytes 0~3 int origin_x
    // Bytes 4~7 int origin_y
    // Bytes 8~11 int len_x
    // Bytes 12~15 int len_y
    // Bytes 16~19 int resolution
    // Bytes 20~23 int scale
    // Bytes 24~27 int block_length
    // Bytes 28~28+len_x*len_y*4 int index_mat
    // Bytes 28+len_x*len_y*4~end unsigned short int[] zipped
    fread(&origin_x, sizeof(origin_x), 1, file);
    fread(&origin_y, sizeof(origin_y), 1, file);
    fread(&len_x, sizeof(len_x), 1, file);
    fread(&len_y, sizeof(len_y), 1, file);
    fread(&resolution, sizeof(resolution), 1, file);
    fread(&scale, sizeof(scale), 1, file);
    fread(&block_length, sizeof(block_length), 1, file);
    min_x = origin_x/1000;
    min_y = origin_y/1000;
    max_x = min_x + len_x - 1;
    max_y = min_y + len_y - 1;
    index_mat = new int[len_x * len_y];
    block_side_length = 1000/resolution;
    block_size = block_side_length * block_side_length;
    fread(index_mat, sizeof(int), len_x * len_y, file);
    zipped = new unsigned short int*[block_length];
    for (int i = 0; i < block_length; i++){
        zipped[i] = new unsigned short int[block_size];
        fread(zipped[i], sizeof(unsigned short int), block_size, file);
    }

    fake = false;
}

ElevationData::~ElevationData(){
    delete[] index_mat;
    for (int i = 0; i < block_length; i++)
        delete[] zipped[i];
    delete[] zipped;
}

bool ElevationData::isfake(){return fake;}

unsigned int ElevationData::getResolution(){return resolution;}

float ElevationData::get_elevation(int x, int y){
    if(!fake){
        int x_km = x/1000, y_km = y/1000;
        // If x,y's block is not contained in index_mat, skipped
        if(x_km<min_x || x_km>max_x || y_km<min_y || y_km>max_y)
            return -1.0f;
        else{
            int index = index_mat[(x_km-min_x)*len_y+(y_km-min_y)];
            // If x,y's block exists in zipped, continue to process elevation value
            if (index+1){
                int x_m = x%1000, y_m = y%1000;
                int x_offset = (x_m-1)/resolution, y_offset = (y_m-1)/resolution;
                unsigned short int zipped_elevation = zipped[index][x_offset*block_side_length + y_offset];
                if (zipped_elevation)
                    return float(zipped_elevation)/scale;
                else
                    return -1.0f;
            }else
                return -1.0f;
        }
    }
    else{
        double r = sqrt((double)x*x + (double)y*y);
        return r<=39112.82854?abs(x)*(0.5*sin(r/300)+0.5)/10:-1.0; 
    }
}
