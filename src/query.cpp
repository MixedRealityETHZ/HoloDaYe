#define _USE_MATH_DEFINES
#include <holodaye/elevation.h>
#include "math.h"

ElevationQuery::ElevationQuery(float x, float y, float theta, ElevationData* data):origin_x(x),origin_y(y),theta(theta),data(data),last_x(x),last_y(y){
    started = false;
    direction_x = cos(theta);
    direction_y = sin(theta);
    resolution = data->getResolution();
    if (direction_x>=0){
        if (direction_y>=0){
            if (direction_x>=direction_y)
                mode = 0; // 0 ~ pi/4
            else
                mode = 1; // pi/4 ~ pi/2
        }
        else{
            if (direction_x>=-direction_y)
                mode = 7; // 7pi/4 ~ 2pi
            else
                mode = 6; // 3pi/2 ~ 7pi/4
        }
    }
    else{
        if (direction_y>=0){
            if (-direction_x>=direction_y)
                mode = 3; // 3pi/4 ~ 2pi
            else
                mode = 2; // pi/2 ~ 3pi/4
        }
        else{
            if (-direction_x>=-direction_y)
                mode = 4; // pi ~ 5pi/4
            else
                mode = 5; // 5pi/4 ~ 3pi/2
        }
    }
}

inline float ElevationQuery::compute_distance(int x,int y,float dx,float dy){
    return x*dx+y*dy;
}

void ElevationQuery::query(float* h, float* d, int length){
    int count = 0;
    if(!started){
        h[0] = data->get_elevation((int)round(origin_x/resolution)*resolution, (int)round(origin_y/resolution)*resolution);
        d[0] = 0.0f;
        switch(mode){
            case 7:
            case 0:
                last_x = (int)ceil(origin_x/resolution)*resolution;
                error = (last_x - origin_x)*direction_y/direction_x + origin_y;
                last_y = (int)round(error/resolution)*resolution;
                error = (error - last_y)/resolution;
                step_size = direction_y/direction_x;
                break;
            case 1:
            case 2:
                last_y = (int)ceil(origin_y/resolution)*resolution;
                error = (last_y - origin_y)*direction_x/direction_y + origin_x;
                last_x = (int)round(error/resolution)*resolution;
                error = (error - last_x)/resolution;
                step_size = direction_x/direction_y;
                break;
            case 3:
            case 4:
                last_x = (int)floor(origin_x/resolution)*resolution;
                error = (last_x - origin_x)*direction_y/direction_x + origin_y;
                last_y = (int)round(error/resolution)*resolution;
                error = (error - last_y)/resolution;
                step_size = -direction_y/direction_x;
                break;
            case 5:
            case 6:
                last_y = (int)floor(origin_y/resolution)*resolution;
                error = (last_y - origin_y)*direction_x/direction_y + origin_x;
                last_x = (int)round(error/resolution)*resolution;
                error = (error - last_x)/resolution;
                step_size = -direction_x/direction_y;
                break;
        }
        count++;
        started = true;
    }
    // Line Rasterization: Bresenham's line algorithm
    switch(mode){
        case 0:
            for(;count<length;count++){
                last_x+=resolution;
                error += step_size;
                if(error>=0.5){
                    last_y+=resolution;
                    error-=1.0;
                }
                h[count] = data->get_elevation(last_x,last_y);
                d[count] = compute_distance(last_x-origin_x, last_y-origin_y,direction_x,direction_y);
            }
            break;
        case 1:
            for(;count<length;count++){
                last_y+=resolution;
                error += step_size;
                if(error>=0.5){
                    last_x+=resolution;
                    error-=1.0;
                }
                h[count] = data->get_elevation(last_x,last_y);
                d[count] = compute_distance(last_x-origin_x, last_y-origin_y,direction_x,direction_y);
            }
            break;
        case 2:
            for(;count<length;count++){
                last_y+=resolution;
                error += step_size;
                if(error<=-0.5){
                    last_x-=resolution;
                    error+=1.0;
                }
                h[count] = data->get_elevation(last_x,last_y);
                d[count] = compute_distance(last_x-origin_x, last_y-origin_y,direction_x,direction_y);
            }
            break;
        case 3:
            for(;count<length;count++){
                last_x-=resolution;
                error += step_size;
                if(error>=0.5){
                    last_y+=resolution;
                    error-=1.0;
                }
                h[count] = data->get_elevation(last_x,last_y);
                d[count] = compute_distance(last_x-origin_x, last_y-origin_y,direction_x,direction_y);
            }
            break;
        case 4:
            for(;count<length;count++){
                last_x-=resolution;
                error += step_size;
                if(error<=-0.5){
                    last_y-=resolution;
                    error+=1.0;
                }
                h[count] = data->get_elevation(last_x,last_y);
                d[count] = compute_distance(last_x-origin_x, last_y-origin_y,direction_x,direction_y);
            }
            break;
        case 5:
            for(;count<length;count++){
                last_y-=resolution;
                error += step_size;
                if(error<=-0.5){
                    last_x-=resolution;
                    error+=1.0;
                }
                h[count] = data->get_elevation(last_x,last_y);
                d[count] = compute_distance(last_x-origin_x, last_y-origin_y,direction_x,direction_y);
            }
            break;
        case 6:
            for(;count<length;count++){
                last_y-=resolution;
                error += step_size;
                if(error>=0.5){
                    last_x+=resolution;
                    error-=1.0;
                }
                h[count] = data->get_elevation(last_x,last_y);
                d[count] = compute_distance(last_x-origin_x, last_y-origin_y,direction_x,direction_y);
            }
            break;
        case 7:
            for(;count<length;count++){
                last_x+=resolution;
                error += step_size;
                if(error<=-0.5){
                    last_y-=resolution;
                    error+=1.0;
                }
                h[count] = data->get_elevation(last_x,last_y);
                d[count] = compute_distance(last_x-origin_x, last_y-origin_y,direction_x,direction_y);
            }
            break;
    }
}