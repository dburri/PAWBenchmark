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
    //[self runPerformanceTest1];
    [self runPerformanceTest2];
}

- (void)runPerformanceTest1
{
    // perform tests
    int numIndTests = 10;
    
    vector<CGSize> imageSizes;
    imageSizes.push_back(CGSizeMake(12, 12));
    imageSizes.push_back(CGSizeMake(16, 16));
    imageSizes.push_back(CGSizeMake(32, 32));
    imageSizes.push_back(CGSizeMake(45, 45));
    imageSizes.push_back(CGSizeMake(64, 64));
    imageSizes.push_back(CGSizeMake(90, 90));
    imageSizes.push_back(CGSizeMake(128, 128));
    imageSizes.push_back(CGSizeMake(181, 181));
    imageSizes.push_back(CGSizeMake(256, 256));
    imageSizes.push_back(CGSizeMake(362, 362));
    imageSizes.push_back(CGSizeMake(512, 512));
    imageSizes.push_back(CGSizeMake(724, 724));
    imageSizes.push_back(CGSizeMake(1024, 1024));
    imageSizes.push_back(CGSizeMake(1448, 1448));
    imageSizes.push_back(CGSizeMake(3264, 2448));
    
    static const int arr[] = {10, 50, 100};
    vector<int> numPoints(arr, arr + sizeof(arr) / sizeof(arr[0]) );
    
    NSMutableString *results = [[NSMutableString alloc] init];
    [results appendString:@"Resolution, #Points, #Triangles, Area Coverage, time GPU, time CPU\n"];
    for(int i = 0; i < imageSizes.size(); ++i)
    {
        [self performRandomTest:imageSizes[i] :4 :YES];
        
        for(int j = 0; j < numPoints.size(); ++j)
        {
            double dtCPU = 0;
            double dtGPU = 0;
            double dtTmp = 0;
            double avgNumTri = 0;
            double avgAreaCov = 0;
            for(int k = 0; k < numIndTests; ++k)
            {
                @autoreleasepool
                {
                    // create test data
                    double area = 0;
                    UIImage *img1 = [self createDummyImage:imageSizes[i]];
                    UIImage *img2;
                    PDMShape *shape1 = [self createDummyShape:numPoints[j] :imageSizes[i]];
                    PDMShape *shape2 = [self perturbShapeRandomly:shape1];
                    NSArray *tri = [self triangulateShape:shape1 :&area];
                    double areaCoverage = area/(imageSizes[i].width*imageSizes[i].height);
                    
                    avgNumTri += [tri count];
                    avgAreaCov += areaCoverage;
            
                    @autoreleasepool {
                        img2 = [self testWidthData:YES :img1 :shape1 :shape2 :tri :&dtTmp];
                        dtGPU += dtTmp;
                    }
                    @autoreleasepool {
                        img2 = [self testWidthData:NO :img1 :shape1 :shape2 :tri :&dtTmp];
                        dtCPU += dtTmp;
                    }
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

- (void)runPerformanceTest2
{
    // perform tests
    int numIndTests = 10;
    
    static const float arr1[] = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0};
    //static const float arr1[] = {0.1, 0.2, 0.3, 0.4};
    //static const float arr1[] = {0.5, 0.6, 0.7, 0.8};
    //static const float arr1[] = {0.9, 1.0};
    vector<float> pixelCoverage(arr1, arr1 + sizeof(arr1) / sizeof(arr1[0]) );
    
    static const int arr2[] = {10, 50, 100};
    vector<int> numPoints(arr2, arr2 + sizeof(arr2) / sizeof(arr2[0]) );
    
    CGSize imgSize = CGSizeMake(1600, 1200);
    [self performRandomTest:imgSize :4 :YES];
    
    NSMutableString *results = [[NSMutableString alloc] init];
    [results appendString:@"Resolution, #Points, #Triangles, Area Coverage, time GPU, time CPU\n"];
    for(int i = 0; i < pixelCoverage.size(); ++i)
    {
        for(int j = 0; j < numPoints.size(); ++j)
        {
            double dtCPU = 0;
            double dtGPU = 0;
            double avgNumTri = 0;
            double avgAreaCov = 0;
            double dtTmp = 0;
            for(int k = 0; k < numIndTests; ++k)
            {
                @autoreleasepool
                {
                    // create test data
                    double area;
                    UIImage *img1 = [self createDummyImage:imgSize];
                    UIImage *img2;
                    PDMShape *shape1 = [self createDummyShapeWithCoverage:numPoints[j] :imgSize :pixelCoverage[i]];
                    PDMShape *shape2 = [self perturbShapeRandomly:shape1];
                    NSArray *tri = [self triangulateShape:shape1 :&area];
                    double areaCoverage = area/(imgSize.width*imgSize.height);
                    
                    avgNumTri += [tri count];
                    avgAreaCov += areaCoverage;
                    
                    
                    // apply test
                    img2 = [self testWidthData:YES :img1 :shape1 :shape2 :tri :&dtTmp];
                    dtGPU += dtTmp;
                    
                    img2 = [self testWidthData:NO :img1 :shape1 :shape2 :tri :&dtTmp];
                    dtCPU += dtTmp;
                }
                
            }
            dtCPU /= numIndTests;
            dtGPU /= numIndTests;
            avgNumTri /= numIndTests;
            avgAreaCov /= numIndTests;
            
            NSLog(@"\nTest finished! Resolution = %i x %i, #Points = %i, #Triangles = %.1f, AreaCov = %f, dtGPU = %1.10f, dtCPU = %1.10f\n", (int)imgSize.width, (int)imgSize.height, numPoints[j], avgNumTri, avgAreaCov, dtGPU, dtCPU);
            
            [results appendFormat:@"%i x %i, %i, %.1f, %.4f, %1.10f, %1.10f\n", (int)imgSize.width, (int)imgSize.height, (int)numPoints[j], avgNumTri, avgAreaCov, dtGPU, dtCPU];
        }
    }
    NSLog(@"%@", results);
}

- (void)runVisualTest
{
    CGSize size = CGSizeMake(320, 240);
    int nPoints = (int)numPSlider.value;
    BOOL usePGU = switchGPU.on;
    
    double area;
    double dt;
    UIImage *img1 = [self createDummyImage:size];
    PDMShape *shape1 = [self createDummyShape:nPoints :size];
    PDMShape *shape2 = [self perturbShapeRandomly:shape1];
    NSArray *tri = [self triangulateShape:shape1 :&area];
    
    UIImage *img2 = [self testWidthData:usePGU :img1 :shape1 :shape2 :tri :&dt];
    
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
    double dt;
    UIImage *img1 = [self createDummyImage:size];
    PDMShape *shape1 = [self createDummyShape:nPoints :size];
    PDMShape *shape2 = [shape1 getCopy];
    NSArray *tri = [self triangulateShape:shape1 :&area];

    [self testWidthData:GPU :img1 :shape1 :shape2 :tri :&dt];
    
    return dt;
}


- (PDMShape*)perturbShapeRandomly:(PDMShape*)s
{
    PDMShape *s2 = [s getCopy];
    for (int i = 0; i < s2.num_points; ++i) {
        s2.shape[i].pos[0] += floorf(((double)arc4random() / ARC4RANDOM_MAX - 0.5) * 80.);
        s2.shape[i].pos[1] += floorf(((double)arc4random() / ARC4RANDOM_MAX - 0.5) * 80.);
    }
    return s2;
}

- (UIImage*)testWidthData:(BOOL)GPU :(UIImage*)img1 :(PDMShape*)shape1 :(PDMShape*)shape2 :(NSArray*)triangles :(double*)dt
{
    NSDate *start = [NSDate date];
    UIImage *tmpImg;
    @autoreleasepool
    {
        if(GPU == YES) {
            tmpImg = [PAW warpImage:img1 :shape1 :shape2 :triangles];
        } else {
            tmpImg = [PAWCPU warpImage:img1 :shape1 :shape2 :triangles];
        }
    }
    NSDate *stop = [NSDate date];
    *dt = [stop timeIntervalSinceDate:start];

    return tmpImg;
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

- (PDMShape*)createDummyShapeWithCoverage:(int)nPoints :(CGSize)size :(float)coverage
{
    assert(coverage <= 1);
    assert(nPoints >= 4);
    assert(size.width > 0 && size.height > 0);
    
    float tol = 0.01;
    
    vector<point_2d_t> points(nPoints);
    float area = 0;
    
    float w = floor(sqrtf(coverage * size.width * size.width));
    float h = floor(size.height / size.width * w);
    
    //NSLog(@"np = %i, c = %f, w = %i, h = %i, wp = %i, hp = %i", nPoints, coverage, (int)size.width, (int)size.height, (int)w, (int)h);
    
    while(abs(coverage-area/(size.width*size.height)) > tol)
    {
        points[0].pos[0] = 0;
        points[0].pos[1] = 0;
        points[1].pos[0] = w;
        points[1].pos[1] = 0;
        points[2].pos[0] = w;
        points[2].pos[1] = h;
        points[3].pos[0] = 0;
        points[3].pos[1] = h;
        
        for(int i = 4; i < nPoints; ++i)
        {
            points[i].pos[0] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * w);
            points[i].pos[1] = floorf(((double)arc4random() / ARC4RANDOM_MAX) * h);
        }
        
        vector<triangle_t> triangles;
        area = delaunay->performDelaunay(-50, -50, w+100, h+100, points, &triangles);
        //NSLog(@"rc = %f, numtri = %i", realCoverage, (int)triangles.size());
    }
    
    point_t *points2 = (point_t*)malloc(nPoints * sizeof(point_t));
    for(int i = 0; i < nPoints; ++i)
    {
        points2[i].pos[0] = points[i].pos[0];
        points2[i].pos[1] = points[i].pos[1];
    }
    
    PDMShape *shape = [[PDMShape alloc] init];
    [shape setNewShapeData:points2 :nPoints];
    
    return shape;
}


- (UIImage*)createDummyImage:(CGSize)size
{
    unsigned char *rawData = (unsigned char*)malloc(size.width*size.height*4);
    unsigned char *data_ptr = &rawData[0];
    double r = 0;
    double dr = 1/(double)size.height;
    double dg = 1/(double)size.width;
    for (int y = 0; y < size.height; ++y)
    {
        double g = 0;
        for (int x = 0; x < size.width; ++x) 
        {
            unsigned char c = (((y & 8) == 0) ^ ((x & 8) == 0));
            
            *data_ptr++ = 255*c*r;      // B
            *data_ptr++ = 255*c*g;      // G
            *data_ptr++ = 255*c;        // R
            *data_ptr++ = 255;          // A
            g += dg;
        }
        r += dr;
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
