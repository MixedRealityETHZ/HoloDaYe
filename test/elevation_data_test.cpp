#include <catch2/catch_test_macros.hpp>
#include <holodaye/elevation.h>
#include <iostream>

TEST_CASE( "Real test for dataset class", "[ElevationData]" ) {
    // Create a mew ElevationData object and test it's basic functionality
    ElevationData *data;
    SECTION( "Checking the correcteness of initialization and destruction" ) {
        data = new ElevationData();
        delete data;
    }
    data = new ElevationData();
    SECTION( "Checking the correcteness of resolution" ) {
        REQUIRE( data->getResolution() == 4 );
        REQUIRE( data->isfake() == false );
    }
    
    SECTION( "Checking the correcteness of getting elevation at a specific location" ) {
        REQUIRE( data->get_elevation(0,0)==-1 );
        REQUIRE( data->get_elevation(3000000,1180001)==-1 );
        REQUIRE( data->get_elevation(2730955,1186001)<2036 );
        REQUIRE( data->get_elevation(2730955,1186001)>2035 );
        REQUIRE( data->get_elevation(2730173,1186907)>2241.6 ); //2730173 1186907 2241.74
        REQUIRE( data->get_elevation(2730173,1186907)<2241.9 );
        
    }
    delete data;
}