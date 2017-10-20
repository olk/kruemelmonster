//          Copyright Oliver Kowalke 2017.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <random>
#include <vector>

#include <cuda.h>

#include "animation.h"

constexpr unsigned int DIM = 2048;
constexpr unsigned int STATES = 15;

__global__
void cell( unsigned int * in, unsigned int * out) {
    // map from threadIdx/BlockIdx to pixel position
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
    if ( x < DIM && y < DIM) {
        int offset = x + y * DIM;
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

__device__
std::tuple< unsigned char, unsigned char, unsigned char >
rgb_from_int( unsigned int state) {
    float f = static_cast< float >(state)/(STATES-1);
    return std::make_tuple(
            static_cast< unsigned char >(255*f),
            static_cast< unsigned char >(0),
            static_cast< unsigned char >(255*(1-f)));
}

__global__
void map( unsigned char* optr, unsigned int * inSrc, unsigned int const* outSrc) {
    // map from threadIdx/BlockIdx to pixel position
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
    if ( x < DIM && y < DIM) {
        int offset = x + y * DIM;
        int state = outSrc[offset];
        inSrc[offset] = state;
        auto t = rgb_from_int( state);
        optr[4 * offset + 0] = std::get<0>( t);
        optr[4 * offset + 1] = std::get<1>( t);
        optr[4 * offset + 2] = std::get<2>( t);
        optr[4 * offset + 3] = 255;
    }
}

int main() {
    constexpr std::size_t size = DIM * DIM * sizeof( unsigned int);
    unsigned int * inSrc = nullptr;
    unsigned int * outSrc = nullptr;
    cudaMallocManaged( & inSrc, size);
    cudaMallocManaged( & outSrc, size);
    std::minstd_rand generator;
    std::uniform_int_distribution<> distribution{ 0, STATES-1 };
    for ( unsigned int i = 0; i < DIM*DIM; ++i) {
        inSrc[i] = distribution( generator); 
        outSrc[i] = inSrc[i];
    }
    animation image{ DIM, DIM };
    unsigned int x = std::ceil( DIM/32.0);
    const dim3 dim_grid{ x, x };
    const dim3 dim_block{ 32, 32 };
    image.display_and_exit(
        [dim_grid,dim_block,&image,size,inSrc,outSrc](unsigned int) mutable {
            cell<<< dim_grid, dim_block >>>( inSrc, outSrc);
            map<<< dim_grid, dim_block >>>( image.get_ptr(), inSrc, outSrc);
            cudaDeviceSynchronize();
        });
    cudaFree( inSrc);
    cudaFree( outSrc);
    return EXIT_SUCCESS;
}
