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
    
}


double Triangulate::performDelaunay(int x, int y, int w, int h, const vector<point_2d_t> &points, vector<triangle_t> *triangles)
{
    //cout << "performDelaunay" << endl;
    triangles->clear();
    
    Rect rect(x,y,w,h);
    Subdiv2D subdiv(rect);
    
    for( int i = 0; i < points.size(); i++ )
    {
        //cout << i << " : [" << points[i].pos[0] << ", " << points[i].pos[1] << "]" << endl;
        Point2f fp(points[i].pos[0], points[i].pos[1]);
        subdiv.insert(fp);
    }
    
    vector<Vec6f> triangleList;
    subdiv.getTriangleList(triangleList);
    vector<Point> pt(3);
    
    vector<triangle_t> triangleIndList;
    
    float tol = 0.000001;
    double area = 0.;
    for( size_t i = 0; i < triangleList.size(); i++ )
    {
        bool f1 = false;
        bool f2 = false;
        bool f3 = false;
        triangle_t tri;
        
        Vec6f t = triangleList[i];
        pt[0] = Point(cvRound(t[0]), cvRound(t[1]));
        pt[1] = Point(cvRound(t[2]), cvRound(t[3]));
        pt[2] = Point(cvRound(t[4]), cvRound(t[5]));

        for(int j = 0; j < points.size(); ++j)
        {
            //cout << "x = " << points[j].pos[0] << ", y = " << points[j].pos[1] << endl;
        
            if(abs(points[j].pos[0] - pt[0].x) < tol && 
               abs(points[j].pos[1] - pt[0].y) < tol) {
                tri.ind[0] = j;
                f1 = true;
            }
            else if(abs(points[j].pos[0] - pt[1].x) < tol && 
                    abs(points[j].pos[1] - pt[1].y) < tol) {
                tri.ind[1] = j;
                f2 = true;
            }
            else if(abs(points[j].pos[0] - pt[2].x) < tol && 
                    abs(points[j].pos[1] - pt[2].y) < tol) {
                tri.ind[2] = j;
                f3 = true;
            }
        }
        
        
        if(f1 && f2 && f3) {
            triangles->push_back(tri);
            area += abs(t[0]*(t[3] - t[5]) + t[2]*(t[5] - t[1]) + t[4]*(t[1] - t[3]))/2;
        }
        
    }
    
    return area;
    
}

