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


@interface ViewController : UIViewController 
{
    IBOutlet View1 *imgView1;
    IBOutlet View1 *imgView2;
    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *numPLabel;
    IBOutlet UISwitch *switchGPU;
    IBOutlet UISlider *numPSlider;
    
    PiecewiseAffineWarp *PAW;
    PiecewiseAffineWarpCPU *PAWCPU;
    
    CGSize imgSize;
}

@property IBOutlet View1 *imgView1;
@property IBOutlet View1 *imgView2;
@property IBOutlet UILabel *timeLabel;
@property IBOutlet UILabel *numPLabel;
@property IBOutlet UISlider *numPSlider;
@property IBOutlet UISwitch *switchGPU;


- (UIImage*)createDummyImage:(CGSize)size;
- (PDMShape*)createDummyShape:(int)nPoints :(CGSize)size;
- (void)testTriangulation;

- (double)performRandomTest:(CGSize)size :(int)nPoints :(BOOL)GPU;

- (IBAction)sliderChanged:(id)sender;
- (IBAction)tapRecongized:(id)sender;

@end
