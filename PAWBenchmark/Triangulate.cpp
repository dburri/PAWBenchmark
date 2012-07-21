//
//  ImageProcessing.cpp
//  OpenCVTest
//
//  Created by DINA BURRI on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "Triangulate.h"

#include <iostream>
#include <vector>
#include <opencv2/opencv.hpp>
#include <opencv2/imgproc/imgproc.hpp>


Triangulate::Triangulate()
{
    std::cout << "ImageProcessing..." << std::endl;
    
    Mat M(2,2, CV_8UC3, Scalar(0,0,255));
    image = &M;
}


void Triangulate::performDelaunay(int w, int h, const point_t *points, int num_points, triangle_t *triangles, int *num_triangles)
{
    cout << "performDelaunay" << endl;
    
    Rect rect(0,0,w,h);
    
    Subdiv2D subdiv(rect);
    
    for( int i = 0; i < num_points; i++ )
    {
        cout << i << " : [" << points[i].pos[0] << ", " << points[i].pos[1] << "]" << endl;
        Point2f fp(points[i].pos[0], points[i].pos[1]);
        subdiv.insert(fp);
    }
    
    vector<Vec6f> triangleList;
    subdiv.getTriangleList(triangleList);
    vector<Point> pt(3);
    
    *num_triangles = triangleList.size();
    triangles = (triangle_t*)malloc((*num_triangles) * sizeof(triangle_t));
    
    for( size_t i = 0; i < triangleList.size(); i++ )
    {
        Vec6f t = triangleList[i];
        cout << "t[0] = " << t[0] << ", t[1] = " << t[1] << ", t[2] = " << t[2] << ", t[3] = " << t[3] << ", t[4] = " << t[4] << ", t[5] = " << t[5] << endl;
        pt[0] = Point(cvRound(t[0]), cvRound(t[1]));
        pt[1] = Point(cvRound(t[2]), cvRound(t[3]));
        pt[2] = Point(cvRound(t[4]), cvRound(t[5]));
    }

    
}

