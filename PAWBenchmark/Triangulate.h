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
} point_2d_t;

typedef struct {
    unsigned int ind[3];
} triangle_t;


class Triangulate
{
    
public:
    Triangulate();
    
    void performDelaunay(int x, int y, int w, int h, const vector<point_2d_t> &points, vector<triangle_t> *triangles);
    
private:
    cv::Mat *image;
    
public:
    
};



#endif
