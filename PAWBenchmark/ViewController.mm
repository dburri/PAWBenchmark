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

@synthesize img1;
@synthesize img2;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    delaunay = new Triangulate;
    
    PAW = [[PiecewiseAffineWarp alloc] init];
    PAWCPU = [[PiecewiseAffineWarpCPU alloc] init];

    img1 = [[UIImage alloc] init];
    img2 = [[UIImage alloc] init];
    shape1 = [[PDMShape alloc] init];
    shape2 = [[PDMShape alloc] init];
    tri = [[NSMutableArray alloc] init];
    
    [self runVisualTest];
    
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

- (IBAction)tapRecongized:(UITapGestureRecognizer*)sender
{
    [self runVisualTest];
}

- (IBAction)sliderChanged:(id)sender
{
    numPLabel.text = [NSString stringWithFormat:@"#Points: %i", (int)numPSlider.value];
}

- (IBAction)startBenchmark:(id)sender
{
    NSLog(@"Start Benchmark...");
    [self runFullBenchmark];
}

- (void)runFullBenchmark
{
    // perform tests
    int numIndTests = 10;
    
    vector<CGSize> imageSizes;
    imageSizes.push_back(CGSizeMake(64, 64));
    imageSizes.push_back(CGSizeMake(320, 240));
    imageSizes.push_back(CGSizeMake(640, 480));
    imageSizes.push_back(CGSizeMake(1024, 768));
    imageSizes.push_back(CGSizeMake(3264, 2448));
    
    static const int arr[] = {4, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100};
    vector<int> numPoints(arr, arr + sizeof(arr) / sizeof(arr[0]) );
    
    NSMutableString *results = [[NSMutableString alloc] init];
    [results appendString:@"Resolution, #Points, #Triangles, Area Coverage, time GPU, time CPU\n"];
    for(int i = 0; i < imageSizes.size(); ++i)
    {
        for(int j = 0; j < numPoints.size(); ++j)
        {
            double dtCPU = 0;
            double dtGPU = 0;
            double avgNumTri = 0;
            double avgAreaCov = 0;
            for(int k = 0; k < numIndTests; ++k)
            {
                [self createTestData:imageSizes[i] :numPoints[j]];
                avgNumTri += [tri count];
                avgAreaCov += areaCoverage;
            
                @autoreleasepool {
                    dtGPU += [self testWidthData:YES];
                }
                
                @autoreleasepool {
                    dtCPU += [self testWidthData:NO];
                }
            }
            dtCPU /= numIndTests;
            dtGPU /= numIndTests;
            avgNumTri /= numIndTests;
            avgAreaCov /= numIndTests;
            
            NSLog(@"\nTest finished! Resolution = %i x %i, #Points = %i, #Triangles = %.1f, AreaCov = %f, dtGPU = %1.10f, dtCPU = %1.10f\n", (int)imageSizes[i].width, (int)imageSizes[i].height, numPoints[j], avgNumTri, avgAreaCov, dtGPU, dtCPU);
            
            [results appendFormat:@"%i x %i, %i, %.1f, %.4f, %1.10f, %1.10f\n", (int)imageSizes[i].width, (int)imageSizes[i].height, (int)numPoints[j], avgNumTri, avgAreaCov, dtGPU, dtCPU];
        }
    }
    NSLog(@"%@", results);
}

- (void)runVisualTest
{
    CGSize size = CGSizeMake(320, 240);
    int nPoints = (int)numPSlider.value;
    double dt = [self performRandomTest:size :nPoints :switchGPU.on];
    timeLabel.text = [NSString stringWithFormat:@"dt = %1.8f", dt];
    
    [imgView1 setNewImage:img1];
    [imgView1 setShape:shape1];
    [imgView1 setTriangles:tri];
    
    [imgView2 setNewImage:img2];
    [imgView2 setShape:shape2];
    [imgView2 setTriangles:tri];
    
    [imgView1 setNeedsDisplay];
    [imgView2 setNeedsDisplay];
}

- (double)performRandomTest:(CGSize)size :(int)nPoints :(BOOL)GPU
{
    double area;
    img1 = [self createDummyImage:size];
    shape1 = [self createDummyShape:nPoints :size];
    shape2 = [shape1 getCopy];
    tri = [self triangulateShape:shape1 :&area];
    areaCoverage = area/(size.width*size.height);

    for (int i = 0; i < shape2.num_points; ++i) {
        shape2.shape[i].pos[0] += floorf(((double)arc4random() / ARC4RANDOM_MAX - 0.5) * 20.);
        shape2.shape[i].pos[1] += floorf(((double)arc4random() / ARC4RANDOM_MAX - 0.5) * 20.);
    }
    
    NSDate *start = [NSDate date];
    if(GPU == YES) {
        img2 = [PAW warpImage:img1 :shape1 :shape2 :tri];
    } else {
        img2 = [PAWCPU warpImage:img1 :shape1 :shape2 :tri];
    }
    NSDate *stop = [NSDate date];
    
    return [stop timeIntervalSinceDate:start];
}

- (void)createTestData:(CGSize)size :(int)nPoints 
{
    double area;
    img1 = [self createDummyImage:size];
    shape1 = [self createDummyShape:nPoints :size];
    shape2 = [shape1 getCopy];
    tri = [self triangulateShape:shape1 :&area];
    areaCoverage = area/(size.width*size.height);
    
    for (int i = 0; i < shape2.num_points; ++i) {
        shape2.shape[i].pos[0] += floorf(((double)arc4random() / ARC4RANDOM_MAX - 0.5) * 20.);
        shape2.shape[i].pos[1] += floorf(((double)arc4random() / ARC4RANDOM_MAX - 0.5) * 20.);
    }
}

- (double)testWidthData:(BOOL)GPU
{
    NSDate *start = [NSDate date];
    if(GPU == YES) {
        img2 = [PAW warpImage:img1 :shape1 :shape2 :tri];
    } else {
        img2 = [PAWCPU warpImage:img1 :shape1 :shape2 :tri];
    }
    NSDate *stop = [NSDate date];

    return [stop timeIntervalSinceDate:start];
}


//---------------------------------------------------------------------------
// TRIANGULATION STUFF

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
    
    NSMutableString *textTri = [[NSMutableString alloc] init];
    [textTri appendFormat:@"\n%i retrieved triangles: \n", triangles.size()];
    for(int i = 0; i < triangles.size(); ++i) {
        [textTri appendFormat:@"[%i, %i, %i]\n", triangles[i].ind[0], triangles[i].ind[1], triangles[i].ind[2]];
    }
    NSLog(@"%@", textTri);
    
}

- (NSArray*)triangulateShape:(PDMShape*)s :(double*)area
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
    *area = delaunay->performDelaunay(rect.origin.x-50, rect.origin.y-50, rect.size.width+100, rect.size.height+100, points, &triangles);
    
    NSMutableArray *trianglesNS = [[NSMutableArray alloc] initWithCapacity:triangles.size()];
    for(int i = 0; i < triangles.size(); ++i) {
        PDMTriangle *triangle = [[PDMTriangle alloc] init];
        triangle.index[0] = triangles[i].ind[0];
        triangle.index[1] = triangles[i].ind[1];
        triangle.index[2] = triangles[i].ind[2];
        [trianglesNS addObject:triangle];
    }
    return trianglesNS;
}

//---------------------------------------------------------------------------
// DUMMY DATA CREATORS

- (PDMShape*)createDummyShape:(int)nPoints :(CGSize)size
{
    assert(nPoints >= 4);
    
    point_t *points = (point_t*)malloc(nPoints * sizeof(point_t));
    
    points[0].pos[0] = 0;
    points[0].pos[1] = 0;
    points[1].pos[0] = size.width-1;
    points[1].pos[1] = 0;
    points[2].pos[0] = size.width-1;
    points[2].pos[1] = size.height-1;
    points[3].pos[0] = 0;
    points[3].pos[1] = size.height-1;
    
    for(int i = 4; i < nPoints; ++i)
    {
        points[i].pos[0] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * (size.width-1));
        points[i].pos[1] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * (size.height-1));
    }
    
    PDMShape *shape = [[PDMShape alloc] init];
    [shape setNewShapeData:points :nPoints];
    return shape;
}


- (UIImage*)createDummyImage:(CGSize)size
{
    unsigned char *rawData = (unsigned char*)malloc(size.width*size.height*4);
    unsigned char *data_ptr = &rawData[0];
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
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
    CGContextRef contextRef = CGBitmapContextCreate(rawData, size.width, size.height, 8, 4*size.width, colorSpaceRef, bitmapInfo);
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(contextRef);
    free(rawData);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return image;
}

@end
