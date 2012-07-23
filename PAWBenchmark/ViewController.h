//
//  ViewController.h
//  PAWBenchmark
//
//  Created by DINA BURRI on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "View1.h"

#import "PDMShape.h"
#import "PDMTriangle.h"
#import "PiecewiseAffineWarp.h"
#import "PiecewiseAffineWarpCPU.h"


@interface ViewController : UIViewController <UIGestureRecognizerDelegate>
{
    IBOutlet View1 *imgView1;
    IBOutlet View1 *imgView2;
    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *numPLabel;
    IBOutlet UISwitch *switchGPU;
    IBOutlet UISlider *numPSlider;
    UIActivityIndicatorView *spinner;
    IBOutlet UITapGestureRecognizer *tapRecognizer;
    
    PiecewiseAffineWarp *PAW;
    PiecewiseAffineWarpCPU *PAWCPU;
    
    UIImage *img1;
    UIImage *img2;
    PDMShape *shape1;
    PDMShape *shape2;
    NSArray *tri;
    double areaCoverage;
    
    CGSize imgSize;
}

@property (retain) IBOutlet View1 *imgView1;
@property (retain) IBOutlet View1 *imgView2;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *numPLabel;
@property (nonatomic, strong) IBOutlet UISlider *numPSlider;
@property (nonatomic, strong) IBOutlet UISwitch *switchGPU;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapRecognizer;

@property (retain) UIImage *img1;
@property (retain) UIImage *img2;


- (UIImage*)createDummyImage:(CGSize)size;
- (PDMShape*)createDummyShape:(int)nPoints :(CGSize)size;
- (void)testTriangulation;

- (double)performRandomTest:(CGSize)size :(int)nPoints :(BOOL)GPU;

- (IBAction)sliderChanged:(id)sender;
- (IBAction)tapRecongized:(UITapGestureRecognizer*)sender;
- (IBAction)startBenchmark:(id)sender;

@end
