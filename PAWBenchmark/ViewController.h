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


@interface ViewController : UIViewController 
{
    IBOutlet View1 *imgView1;
    IBOutlet View1 *imgView2;
}

@property IBOutlet View1 *imgView1;
@property IBOutlet View1 *imgView2;


- (UIImage*)createDummyImage:(CGSize)size;
- (PDMShape*)createDummyShape:(int)nPoints :(CGSize)size;
- (void)testTriangulation;

@end
