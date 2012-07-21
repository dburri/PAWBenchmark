//
//  ViewController.h
//  PAWBenchmark
//
//  Created by DINA BURRI on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController 
{
    IBOutlet UIImageView *imgView1;
    IBOutlet UIImageView *imgView2;
}

@property IBOutlet UIImageView *imgView1;
@property IBOutlet UIImageView *imgView2;


- (UIImage*)createDummyImage:(CGSize)size;
- (void)testTriangulation;

@end
