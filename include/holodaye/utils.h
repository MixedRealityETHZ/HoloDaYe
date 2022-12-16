#include <stdio.h>
#include <list>

using namespace std;




struct GPS {
    double lon, lat, alt;
};

struct LV95 {
    int E, N, H;
};

typedef struct GPS Struct1;
typedef struct LV95 Struct2;

// Convert LV95 format to GPS format
Struct1 LV952GPS(int E, int N, double H);
// Convert GPS format to LV95 format
Struct2 GPS2LV95(double lon, double lat, double alt);

// Print nested list
void printNestedList(list<list<double> > nested_list);