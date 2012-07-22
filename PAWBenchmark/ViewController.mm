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
@synthesize timeLabel;
@synthesize numPLabel;
@synthesize numPSlider;
@synthesize switchGPU;
@synthesize tapRecognizer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    delaunay = new Triangulate;
    
    PAW = [[PiecewiseAffineWarp alloc] init];
    PAWCPU = [[PiecewiseAffineWarpCPU alloc] init];

    
    imgSize = CGSizeMake(800, 600);
    int nPoints = 10;
    double dt = [self performRandomTest:imgSize :nPoints :YES];

    timeLabel.text = [NSString stringWithFormat:@"dt = %1.8f", dt];
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


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint p = [touch locationInView:self.view];
    if(p.y > (imgView1.frame.size.height + imgView2.frame.size.height )) {
        return NO;
    }
    return YES;
}

- (IBAction)startBenchmark:(id)sender
{
    NSLog(@"Start Benchmark...");
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0)];
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.frame];
    [darkView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    [self.view addSubview:darkView];
    
    
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    
    [self runFullBenchmark];
    
    
    
    [spinner stopAnimating];
    [darkView removeFromSuperview];
}


- (void)runFullBenchmark
{
    // perform tests
    int numIndTests = 10;
    
    vector<CGSize> imageSizes(1);
    imageSizes[0] = CGSizeMake(320, 240);
    //imageSizes[1] = CGSizeMake(640, 480);
    //imageSizes[2] = CGSizeMake(1024, 768);
    //imageSizes[3] = CGSizeMake(3264, 2448);

    //static const int arr[] = {3, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100};
    //static const int arr[] = {3, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100};
    static const int arr[] = {3, 5, 10, 20, 30, 40};
    vector<int> numPoints(arr, arr + sizeof(arr) / sizeof(arr[0]) );
    
    NSMutableString *results = [[NSMutableString alloc] init];
    [results appendString:@"Resolution, #Points, time GPU, time CPU\n"];
    for(int i = 0; i < imageSizes.size(); ++i)
    {
        for(int j = 0; j < numPoints.size(); ++j)
        {
            double dtCPU = 0;
            double dtGPU = 0;
            for(int k = 0; k < numIndTests; ++k)
            {
                dtGPU += [self performRandomTest:imageSizes[i] :numPoints[j] :YES];
                dtCPU += [self performRandomTest:imageSizes[i] :numPoints[j] :NO];
                sleep(0.5);
            }
            dtCPU /= numIndTests;
            dtGPU /= numIndTests;
            NSLog(@"\nTest finished! Resolution = %f x %f, #Points = %i, dtGPU = %1.10f, dtCPU = %1.10f\n", imageSizes[i].width, imageSizes[i].height, numPoints[j], dtGPU, dtCPU);
            [results appendFormat:@"%f x %f, %i, %1.10f, %1.10f\n", imageSizes[i].width, imageSizes[i].height, numPoints[j], dtGPU, dtCPU];
        }
    }
    NSLog(@"%@", results);
    
    
}


- (IBAction)tapRecongized:(UITapGestureRecognizer*)sender
{
    CGSize size = imgSize;
    int nPoints = (int)numPSlider.value;
    double dt = [self performRandomTest:size :nPoints :switchGPU.on];
    timeLabel.text = [NSString stringWithFormat:@"dt = %1.8f", dt];
    
    [imgView1 setNeedsDisplay];
    [imgView2 setNeedsDisplay];
}

- (IBAction)sliderChanged:(id)sender
{
    numPLabel.text = [NSString stringWithFormat:@"#Points: %i", (int)numPSlider.value];
}

- (double)performRandomTest:(CGSize)size :(int)nPoints :(BOOL)GPU
{
    UIImage *img1 = [self createDummyImage:size];
    PDMShape *shape1 = [self createDummyShape:nPoints :size];
    PDMShape *shape2 = [shape1 getCopy];
    NSArray *tri = [self triangulateShape:shape1];

    for (int i = 0; i < shape2.num_points; ++i) {
        shape2.shape[i].pos[0] += floorf(((double)arc4random() / ARC4RANDOM_MAX - 0.5) * 20.);
        shape2.shape[i].pos[1] += floorf(((double)arc4random() / ARC4RANDOM_MAX - 0.5) * 20.);
    }
    UIImage *img2;
    NSDate *start = [NSDate date];
    if(GPU == YES) {
        img2 = [PAW warpImage:img1 :shape1 :shape2 :tri];
    } else {
        img2 = [PAWCPU warpImage:img1 :shape1 :shape2 :tri];
    }
    NSDate *stop = [NSDate date];
    
    [imgView1 setImage:img1];
    [imgView1 setShape:shape1];
    [imgView1 setTriangles:tri];
    
    [imgView2 setImage:img2];
    [imgView2 setShape:shape2];
    [imgView2 setTriangles:tri];
    
    return [stop timeIntervalSinceDate:start];
}



- (void)testTriangulation
{
    int nPoints = 3;
    vector<point_2d_t> points;
    for(int i = 0; i < nPoints; ++i)
    {
        point_2d_t point;
        point.pos[0] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * 10.0f);
        point.pos[1] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * 10.0f);
        points.push_back(point);
    }
    
    vector<triangle_t> triangles;
    delaunay->performDelaunay(0, 0, 100, 100, points, &triangles);
    
    NSMutableString *text = [[NSMutableString alloc] init];
    [text appendFormat:@"\n%i retrieved triangles: \n", triangles.size()];
    for(int i = 0; i < triangles.size(); ++i) {
        [text appendFormat:@"[%i, %i, %i]\n", triangles[i].ind[0], triangles[i].ind[1], triangles[i].ind[2]];
    }
    NSLog(@"%@", text);
    
}

- (PDMShape*)createDummyShape:(int)nPoints :(CGSize)size
{
    point_t *points = (point_t*)malloc(nPoints * sizeof(point_t));
    
    for(int i = 0; i < nPoints; ++i)
    {
        points[i].pos[0] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * size.width);
        points[i].pos[1] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * size.height);
    }
    
    PDMShape *shape = [[PDMShape alloc] init];
    [shape setNewShapeData:points :nPoints];
    return shape;
}

- (NSArray*)triangulateShape:(PDMShape*)s
{
    int nPoints = s.num_points;
    vector<point_2d_t> points(nPoints);
    for(int i = 0; i < nPoints; ++i)
    {
        points[i].pos[0] = s.shape[i].pos[0];
        points[i].pos[1] = s.shape[i].pos[1];
    }
    
    CGRect rect = [s getMinBoundingBox];
    vector<triangle_t> triangles;
    delaunay->performDelaunay(rect.origin.x-50, rect.origin.y-50, rect.size.width+100, rect.size.height+100, points, &triangles);
    
    NSMutableArray *trianglesNS = [[NSMutableArray alloc] initWithCapacity:triangles.size()];
    for(int i = 0; i < triangles.size(); ++i) {
        PDMTriangle *tri = [[PDMTriangle alloc] init];
        tri.index[0] = triangles[i].ind[0];
        tri.index[1] = triangles[i].ind[1];
        tri.index[2] = triangles[i].ind[2];
        [trianglesNS addObject:tri];
    }
    
    return trianglesNS;
}


- (UIImage*)createDummyImage:(CGSize)size
{
    unsigned char *rawData = (unsigned char*)malloc(size.width*size.height*4);
    unsigned char *data_ptr = rawData;
    for (int y = 0; y < size.height; ++y)
    {
        for (int x = 0; x < size.width; ++x) 
        {
            unsigned char c = (((y & 8) == 0) ^ ((x & 8) == 0)) * 128 + 127;
            
            *data_ptr++ = c;
            *data_ptr++ = c;
            *data_ptr++ = c;
            *data_ptr++ = c;
        }
    }
    
//    int bitsPerComponent = 8;
//    int bitsPerPixel = 32;
//    int bytesPerRow = 4*size.width;
    //CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGBA();
    //CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
    
//    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
//    CGImageRef imageRef = CGImageCreate(size.width, size.height, 8, 32, 4*size.width,colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    CGContextRef contextRef = CGBitmapContextCreate(rawData, size.width, size.height, 8, 4*size.width, colorSpaceRef, bitmapInfo);
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    
    CGColorSpaceRelease(colorSpaceRef);
    free(rawData);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(contextRef);


    return image;
}

@end
