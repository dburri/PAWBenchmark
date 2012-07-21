//
//  ImageProcessing.h
//  OpenCVTest
//
//  Created by DINA BURRI on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef OpenCVTest_ImageProcessing_h
#define OpenCVTest_ImageProcessing_h

#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

typedef struct {
    float pos[2];
} point_t;

typedef struct {
    unsigned int ind[3];
} triangle_t;


class Triangulate
{
    
public:
    Triangulate();
    
    void performDelaunay(int w, int h, const point_t *points, int num_points, triangle_t *triangles, int *num_triangles);
    
private:
    cv::Mat *image;
    
public:
    
};



#endif
