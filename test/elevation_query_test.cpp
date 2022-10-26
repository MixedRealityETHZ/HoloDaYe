#include <catch2/catch_test_macros.hpp>
#include <holodaye/elevation.h>
#define _USE_MATH_DEFINES
#include <math.h>

TEST_CASE( "Test for query class", "[ElevationQuery]" ) {
    // Create a mew ElevationData
    ElevationData *data = new ElevationData();
    REQUIRE( data->getResolution() == 20 );
    REQUIRE( data->isfake() == true );
    // Create a mew ElevationQuery object and test it's basic functionality
    SECTION( "Check querying for 1 element" ) {
        ElevationQuery query(4,4,atan(0.4),data); // (x,y) = (4,4), tan(theta)=0.4
        float h[1],d[1];
        query.query(h,d,1);
        REQUIRE( h[0] == data->get_elevation(0,0) );
    }
    SECTION( "Check querying for consecutive 5 elements" ) {
        ElevationQuery query(4,4,atan(0.4),data); // (x,y) = (4,4), tan(theta)=0.4
        float h[5],d[5];
        query.query(h,d,5);// (4,4),(40,18.4),(60,26.4),(80,34.4),(100,42.4)
        REQUIRE( h[0] == data->get_elevation(0,0) );
        REQUIRE( h[1] == data->get_elevation(40,20) );
        REQUIRE( h[2] == data->get_elevation(60,20) );
        REQUIRE( h[3] == data->get_elevation(80,40) );
        REQUIRE( h[4] == data->get_elevation(100,40) );
    }
    SECTION( "Check querying for discreate 8 elements" ) {
        ElevationQuery query(4,4,atan(0.4),data); // (x,y) = (4,4), tan(theta)=0.4
        // (4,4),(40,18.4),(60,26.4),
        // (80,34.4),(100,42.4), (120, 50.8)
        // (140, 58.8), (160,66.8)
        float h[5],d[5];
        query.query(h,d,3);
        REQUIRE( h[0] == data->get_elevation(0,0) );
        REQUIRE( h[1] == data->get_elevation(40,20) );
        REQUIRE( h[2] == data->get_elevation(60,20) );
        query.query(h,d,3);
        REQUIRE( h[0] == data->get_elevation(80,40) );
        REQUIRE( h[1] == data->get_elevation(100,40) );
        REQUIRE( h[2] == data->get_elevation(120,60) );
        query.query(h,d,2);
        REQUIRE( h[0] == data->get_elevation(140,60) );
        REQUIRE( h[1] == data->get_elevation(160,60) );
    }
    SECTION( "Check querying for discreate 5 elements in different angle(45~90)" ) {
        ElevationQuery query(4,4,atan(2.5),data); // (x,y) = (4,4), tan(theta)=0.4
        float h[5],d[5];
        query.query(h,d,5);// (4,4),(18.4,40),(26.4,60),(34.4,80),(42.4,100)
        REQUIRE( h[0] == data->get_elevation(0,0) );
        REQUIRE( h[1] == data->get_elevation(20,40) );
        REQUIRE( h[2] == data->get_elevation(20,60) );
        REQUIRE( h[3] == data->get_elevation(40,80) );
        REQUIRE( h[4] == data->get_elevation(40,100) );
    }
    SECTION( "Check querying for discreate 5 elements in different angle(90~135)" ) {
        ElevationQuery query(4,4, atan(-2.5)+M_PI, data); // (x,y) = (4,4), tan(theta)=-2.5
        float h[5],d[5];
        query.query(h,d,5); // (4,4),(-10.4,40),(-18.4,60),(-26.4,80),(-34.4,100)
        REQUIRE( h[0] == data->get_elevation(0,0) );
        REQUIRE( h[1] == data->get_elevation(-20,40) );
        REQUIRE( h[2] == data->get_elevation(-20,60) );
        REQUIRE( h[3] == data->get_elevation(-20,80) );
        REQUIRE( h[4] == data->get_elevation(-40,100) );
    }
    SECTION( "Check querying for discreate 5 elements in different angle(135~180)" ) {
        ElevationQuery query(4,4, atan(-0.4)+M_PI, data); // (x,y) = (4,4), tan(theta)=-0.4
        float h[5],d[5];
        query.query(h,d,5); // (4,4),(-20,13.6),(-40,21.6),(-60,29.6),(-80,37.6)
        REQUIRE( h[0] == data->get_elevation(0,0) );
        REQUIRE( h[1] == data->get_elevation(-20,20) );
        REQUIRE( h[2] == data->get_elevation(-40,20) );
        REQUIRE( h[3] == data->get_elevation(-60,20) );
        REQUIRE( h[4] == data->get_elevation(-80,40) );
    }
    SECTION( "Check querying for discreate 6 elements in different angle(180~225)" ) {
        ElevationQuery query(4,4, atan(0.4)+M_PI, data); // (x,y) = (4,4), tan(theta)=0.4
        float h[6],d[6];
        query.query(h,d,6); // (4,4),(-20,-5.6),(-40,-13.6),(-60,-21.6),(-80,-29.6),(-100,-37.6)
        REQUIRE( h[0] == data->get_elevation(0,0) );
        REQUIRE( h[1] == data->get_elevation(-20,0) );
        REQUIRE( h[2] == data->get_elevation(-40,-20) );
        REQUIRE( h[3] == data->get_elevation(-60,-20) );
        REQUIRE( h[4] == data->get_elevation(-80,-20) );
        REQUIRE( h[5] == data->get_elevation(-100,-40) );
    }
    SECTION( "Check querying for discreate 6 elements in different angle(225~270)" ) {
        ElevationQuery query(4,4, atan(2.5)+M_PI, data); // (x,y) = (4,4), tan(theta)=2.5
        float h[6],d[6];
        query.query(h,d,6); // (4,4),(-5.6,-20),(-13.6,-40),(-21.6,-60),(-29.6,-80),(-37.6,-100)
        REQUIRE( h[0] == data->get_elevation(0,0) );
        REQUIRE( h[1] == data->get_elevation(0,-20) );
        REQUIRE( h[2] == data->get_elevation(-20,-40) );
        REQUIRE( h[3] == data->get_elevation(-20,-60) );
        REQUIRE( h[4] == data->get_elevation(-20,-80) );
        REQUIRE( h[5] == data->get_elevation(-40,-100) );
    }
    SECTION( "Check querying for discreate 6 elements in different angle(225~270)" ) {
        ElevationQuery query(4,4, atan(-2.5), data); // (x,y) = (4,4), tan(theta)=-2.5
        float h[6],d[6];
        query.query(h,d,6); // (4,4),(13.6,-20),(21.6,-40),(29.6,-60),(37.6,-80),(45.5,-100)
        REQUIRE( h[0] == data->get_elevation(0,0) );
        REQUIRE( h[1] == data->get_elevation(20,-20) );
        REQUIRE( h[2] == data->get_elevation(20,-40) );
        REQUIRE( h[3] == data->get_elevation(20,-60) );
        REQUIRE( h[4] == data->get_elevation(40,-80) );
        REQUIRE( h[5] == data->get_elevation(40,-100) );
    }
    SECTION( "Check querying for discreate 6 elements in different angle(225~270)" ) {
        ElevationQuery query(4,4, atan(-0.4), data); // (x,y) = (4,4), tan(theta)=-0.4
        float h[6],d[6];
        query.query(h,d,6); // (4,4),(40,-10.4),(60,-18.4),(80,-26.4),(100,-34.4),(120,-42.4)
        REQUIRE( h[0] == data->get_elevation(0,0) );
        REQUIRE( h[1] == data->get_elevation(40,-20) );
        REQUIRE( h[2] == data->get_elevation(60,-20) );
        REQUIRE( h[3] == data->get_elevation(80,-20) );
        REQUIRE( h[4] == data->get_elevation(100,-40) );
        REQUIRE( h[5] == data->get_elevation(120,-40) );
    }
    delete data;
}