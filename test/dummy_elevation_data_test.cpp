#include <catch2/catch_test_macros.hpp>
#include <holodaye/elevation.h>

TEST_CASE( "Dummy test for dataset class", "[ElevationData]" ) {
    // Create a mew ElevationData object and test it's basic functionality
    ElevationData *data = new ElevationData();
    REQUIRE( data->getResolution() == 20 );
    REQUIRE( data->isfake() == true );
    
    SECTION( "Checking the correcteness of getting elevation at a specific location" ) {
        REQUIRE( data->get_elevation(10,10)>=0 );
        REQUIRE( data->get_elevation(60000,60000)<0 );
        const int test_boundary = 60000;
        const double zero_boundary = 39112.82854; 
        for(int i = 0; i < 10000; i++){
            int x = std::rand()%(test_boundary*2) - test_boundary;
            int y = std::rand()%(test_boundary*2) - test_boundary;
            double temp = (double)x*x+(double)y*y;
            if (temp <=zero_boundary*zero_boundary-10)
                REQUIRE( data->get_elevation(x,y)>=0 );
            else if (temp >=zero_boundary*zero_boundary+10)
                REQUIRE( data->get_elevation(x,y)<0 );
        }
    }
    delete data;
}