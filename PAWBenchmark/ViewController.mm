//
//  ViewController.m
//  PAWBenchmark
//
//  Created by DINA BURRI on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#include "Triangulate.h"

#define ARC4RANDOM_MAX      0x100000000

@interface ViewController () {
Triangulate *delaunay;
}
@end

@implementation ViewController

@synthesize imgView1;
@synthesize imgView2;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    delaunay = new Triangulate;
    
    UIImage *img = [self createDummyImage:CGSizeMake(32, 32)];
    imgView1.image = img;
    
    [self testTriangulation];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    delete delaunay;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)testTriangulation
{
    int nPoints = 3;
    point_t *points = (point_t*)malloc(nPoints*sizeof(point_t));
    for(int i = 0; i < nPoints; ++i)
    {
        points[i].pos[0] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * 100.0f);
        points[i].pos[1] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * 100.0f);
    }
    
    int nTriangles;
    triangle_t *triangles = NULL;
    delaunay->performDelaunay(100, 100, points, nPoints, triangles, &nTriangles);
    
    
}



- (UIImage*)createDummyImage:(CGSize)size
{
    unsigned char *rawData = (unsigned char*)malloc(size.width*size.height*4);
    unsigned char *data_ptr = rawData;
    for (int y = 0; y < size.height; ++y)
    {
        for (int x = 0; x < size.width; ++x) 
        {
            unsigned char c = (((y & 8) == 0) ^ ((x & 8) == 0)) * 255;
            
            *data_ptr++ = c;
            *data_ptr++ = c;
            *data_ptr++ = c;
            *data_ptr++ = c;
        }
    }

    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, rawData, size.width*size.height*4, NULL);
    
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4*size.width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(size.width, size.height, 8, 32, 4*size.width,colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];

    return image;
}

@end
