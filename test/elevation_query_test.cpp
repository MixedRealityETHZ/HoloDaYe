#include <catch2/catch_test_macros.hpp>
#include <holodaye/elevation.h>
#define _USE_MATH_DEFINES
#include <math.h>

TEST_CASE( "Test for query class", "[ElevationQuery]" ) {
    // Create a mew ElevationData
    ElevationData *data = new ElevationData();
    REQUIRE( data->getResolution() == 4 );
    REQUIRE( data->isfake() == false );
    // Create a mew ElevationQuery object and test it's basic functionality
    int center_x = 2684025;
    int center_y = 1248997; 
    int scale = 14;
    SECTION( "Check querying for 1 element" ) {
        ElevationQuery query(center_x+1,center_y+1,atan(0.4),data); // (x,y) = (2684023,1248999), tan(theta)=0.4
        float h[1],d[1];
        query.query(h,d,1);
        REQUIRE( h[0] == data->get_elevation(center_x,center_y) );
    }
    SECTION( "Check querying for consecutive 5 elements" ) {
        ElevationQuery query(center_x+1,center_y+1,atan(0.4),data); // (x,y) = (1, 1), tan(theta)=0.4
        float h[5],d[5];
        query.query(h,d,5);// (0,0),(8,3.8),(12,5.4),(16,7),(20,8.6)
        REQUIRE( h[0] == data->get_elevation(center_x,center_y) );
        REQUIRE( h[1] == data->get_elevation(center_x+8,center_y+4) );
        REQUIRE( h[2] == data->get_elevation(center_x+12,center_y+4) );
        REQUIRE( h[3] == data->get_elevation(center_x+16,center_y+8) );
        REQUIRE( h[4] == data->get_elevation(center_x+20,center_y+8) );
    }
    SECTION( "Check querying for discreate 8 elements" ) {
        ElevationQuery query(center_x+1,center_y+1,atan(0.4),data); // (x,y) = (1, 1), tan(theta)=0.4
        // (0,0),(8,3.8),(12,5.4),
        // (16,7),(20,8.6),(24,10.2)
        // (28,11.8),(24,13.4)
        float h[5],d[5];
        query.query(h,d,3);
        REQUIRE( h[0] == data->get_elevation(center_x,center_y) );
        REQUIRE( h[1] == data->get_elevation(center_x+8,center_y+4) );
        REQUIRE( h[2] == data->get_elevation(center_x+12,center_y+4) );
        query.query(h,d,3);
        REQUIRE( h[0] == data->get_elevation(center_x+16,center_y+8) );
        REQUIRE( h[1] == data->get_elevation(center_x+20,center_y+8) );
        REQUIRE( h[2] == data->get_elevation(center_x+24,center_y+12) );
        query.query(h,d,2);
        REQUIRE( h[0] == data->get_elevation(center_x+28,center_y+12) );
        REQUIRE( h[1] == data->get_elevation(center_x+32,center_y+12) );
    }
    SECTION( "Check querying for discreate 5 elements in different angle(45~90)" ) {
        ElevationQuery query(center_x+1,center_y+1,atan(2.5),data); // (x,y) = (1, 1), tan(theta)=0.4
        float h[5],d[5];
        query.query(h,d,5);// (0,0),(3.8,8),(5.4,12),(7,16),(8.6,20)
        REQUIRE( h[0] == data->get_elevation(center_x,center_y) );
        REQUIRE( h[1] == data->get_elevation(center_x+4,center_y+8) );
        REQUIRE( h[2] == data->get_elevation(center_x+4,center_y+12) );
        REQUIRE( h[3] == data->get_elevation(center_x+8,center_y+16) );
        REQUIRE( h[4] == data->get_elevation(center_x+8,center_y+20) );
    }
    SECTION( "Check querying for discreate 5 elements in different angle(90~135)" ) {
        ElevationQuery query(center_x+1, center_y+1, atan(-2.5)+M_PI, data); // (x,y) = (1, 1), tan(theta)=-2.5
        float h[5],d[5];
        query.query(h,d,5); // (0,0),(-1.8,8),(-3.4,12),(-5,16),(-6.6,20)
        REQUIRE( h[0] == data->get_elevation(center_x,center_y) );
        REQUIRE( h[1] == data->get_elevation(center_x,center_y+8) );
        REQUIRE( h[2] == data->get_elevation(center_x-4,center_y+12) );
        REQUIRE( h[3] == data->get_elevation(center_x-4,center_y+16) );
        REQUIRE( h[4] == data->get_elevation(center_x-8,center_y+20) );
    }
    SECTION( "Check querying for discreate 5 elements in different angle(135~180)" ) {
        ElevationQuery query(center_x+1, center_y+1, atan(-0.4)+M_PI, data); // (x,y) = (1, 1), tan(theta)=-0.4
        float h[5],d[5];
        query.query(h,d,5); // (0,0),(-4,3),(-8,4.6),(-12,6.2),(-16,7.8)
        REQUIRE( h[0] == data->get_elevation(center_x,center_y) );
        REQUIRE( h[1] == data->get_elevation(center_x-4,center_y+4) );
        REQUIRE( h[2] == data->get_elevation(center_x-8,center_y+4) );
        REQUIRE( h[3] == data->get_elevation(center_x-12,center_y+8) );
        REQUIRE( h[4] == data->get_elevation(center_x-16,center_y+8) );
    }
    SECTION( "Check querying for discreate 6 elements in different angle(180~225)" ) {
        ElevationQuery query(center_x+1, center_y+1, atan(0.4)+M_PI, data); // (x,y) = (1, 1), tan(theta)=0.4
        float h[6],d[6];
        query.query(h,d,6); // (0,0),(-4,-1),(-8,-2.6),(-12,-4.2),(-16,-5.8),(-20,-7.4)
        REQUIRE( h[0] == data->get_elevation(center_x,center_y) );
        REQUIRE( h[1] == data->get_elevation(center_x-4,center_y) );
        REQUIRE( h[2] == data->get_elevation(center_x-8,center_y-4) );
        REQUIRE( h[3] == data->get_elevation(center_x-12,center_y-4) );
        REQUIRE( h[4] == data->get_elevation(center_x-16,center_y-4) );
        REQUIRE( h[5] == data->get_elevation(center_x-20,center_y-8) );
    }
    SECTION( "Check querying for discreate 6 elements in different angle(225~270)" ) {
        ElevationQuery query(center_x+1, center_y+1, atan(2.5)+M_PI, data); // (x,y) = (1, 1), tan(theta)=2.5
        float h[6],d[6];
        query.query(h,d,6); // (0,0),(-1,-4),(-2.6,-8),(-4.2,-12),(-5.8,-16),(-7.4,-20)
        REQUIRE( h[0] == data->get_elevation(center_x,center_y) );
        REQUIRE( h[1] == data->get_elevation(center_x,center_y-4) );
        REQUIRE( h[2] == data->get_elevation(center_x-4,center_y-8) );
        REQUIRE( h[3] == data->get_elevation(center_x-4,center_y-12) );
        REQUIRE( h[4] == data->get_elevation(center_x-4,center_y-16) );
        REQUIRE( h[5] == data->get_elevation(center_x-8,center_y-20) );
    }
    SECTION( "Check querying for discreate 6 elements in different angle(225~270)" ) {
        ElevationQuery query(center_x+1, center_y+1, atan(-2.5), data); // (x,y) = (1, 1), tan(theta)=-2.5
        float h[6],d[6];
        query.query(h,d,6); // (0,0),(3,-4),(4.6,-8),(6.2,-12),(7.8,-16),(9.4,-20)
        REQUIRE( h[0] == data->get_elevation(center_x,center_y) );
        REQUIRE( h[1] == data->get_elevation(center_x+4,center_y-4) );
        REQUIRE( h[2] == data->get_elevation(center_x+4,center_y-8) );
        REQUIRE( h[3] == data->get_elevation(center_x+8,center_y-12) );
        REQUIRE( h[4] == data->get_elevation(center_x+8,center_y-16) );
        REQUIRE( h[5] == data->get_elevation(center_x+8,center_y-20) );
    }
    SECTION( "Check querying for discreate 6 elements in different angle(225~270)" ) {
        ElevationQuery query(center_x+1, center_y+1, atan(-0.4), data); // (x,y) = (1, 1), tan(theta)=-0.4
        float h[6],d[6];
        query.query(h,d,6); // (0,0),(8,-1.8),(12,-3.4),(16,-5),(20,-6.6),(24,-8.2)
        REQUIRE( h[0] == data->get_elevation(center_x,center_y) );
        REQUIRE( h[1] == data->get_elevation(center_x+8,center_y) );
        REQUIRE( h[2] == data->get_elevation(center_x+12,center_y-4) );
        REQUIRE( h[3] == data->get_elevation(center_x+16,center_y-4) );
        REQUIRE( h[4] == data->get_elevation(center_x+20,center_y-8) );
        REQUIRE( h[5] == data->get_elevation(center_x+24,center_y-8) );
    }
    delete data;
}