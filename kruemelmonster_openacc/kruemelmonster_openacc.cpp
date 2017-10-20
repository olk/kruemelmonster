//          Copyright Oliver Kowalke 2017.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iomanip>
#include <iostream>
#include <random>
#include <tuple>

#include "animation.h"

constexpr unsigned int DIM = 2048;
constexpr unsigned int STATES = 15;

void cell( unsigned int * in, unsigned int * out) {
    #pragma acc parallel loop collapse(2) async
    for ( unsigned int y = 0; y < DIM; ++y) {
        for ( unsigned int x = 0; x < DIM; ++x) {
            unsigned int offset = y * DIM + x;
            unsigned int t = in[x+(y+1)%DIM*DIM];
            unsigned int l = in[(0 == x) ? DIM-1+y*DIM : (x-1)%DIM+y*DIM];
            unsigned int c = in[offset];
            unsigned int r = in[(x+1)%DIM+y*DIM];
            unsigned int b = in[(0 == y) ? x+(DIM-1)*DIM : x+(y-1)%DIM*DIM];
            unsigned int tm = t % STATES;
            unsigned int lm = l % STATES;
            unsigned int cm = (c + 1) % STATES;
            unsigned int rm = r % STATES;
            unsigned int bm = b % STATES;
            if ( tm == cm) { 
                out[offset] = t;
            } else if ( lm == cm) {
                out[offset] = l;
            } else if ( rm == cm) {
                out[offset] = r;
            } else if ( bm == cm) {
                out[offset] = b;
            } 
        }
    }
}

auto rgb_from_int( unsigned int state) {
    float f = static_cast< float >(state)/(STATES-1);
    return std::make_tuple(
            static_cast< unsigned char >(255*f),
            static_cast< unsigned char >(0.),
            static_cast< unsigned char >(255*(1-f)));
}

void map( unsigned char* optr, unsigned int * inSrc, unsigned int const* outSrc) {
    #pragma acc parallel loop
    for ( unsigned int offset = 0; offset < DIM * DIM; ++offset) {
        auto state = outSrc[offset];
        inSrc[offset] = state;
        std::tie( optr[4 * offset + 0],
                  optr[4 * offset + 1],
                  optr[4 * offset + 2] ) = rgb_from_int( state);
        optr[4 * offset + 3] = 255;
    }
}

int main() {
    constexpr std::size_t size = DIM * DIM * sizeof( unsigned int);
    unsigned int * inSrc = static_cast< unsigned int * >( std::malloc( size) );
    unsigned int * outSrc = static_cast< unsigned int * >( std::malloc( size) );
    std::minstd_rand generator;
    std::uniform_int_distribution<> distribution{ 0, STATES-1 };
    for ( unsigned int i = 0; i < DIM * DIM; ++i) {
        inSrc[i] = distribution( generator); 
        outSrc[i] = inSrc[i];
    }
    animation image{ DIM, DIM };
    image.display_and_exit(
        [&image,size,inSrc,outSrc](unsigned int) mutable {
            cell( inSrc, outSrc);
            map( image.get_ptr(), inSrc, outSrc);
        });
    std::free( inSrc);
    std::free( outSrc);
    return EXIT_SUCCESS;
}
