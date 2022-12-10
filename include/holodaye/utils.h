#include <stdio.h>



struct GPS {
    double lon, lat, alt;
};

struct LV95 {
    int E, N;
};

typedef struct GPS Struct1;
typedef struct LV95 Struct2;

// Convert LV95 format to GPS format
Struct1 LV952GPS(int E, int N, double H);
// Convert GPS format to LV95 format
Struct2 GPS2LV95(double lon, double lat);
