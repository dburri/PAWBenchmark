//
//  View1.h
//  PAWBenchmark
//
//  Created by DINA BURRI on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDMShape.h"
#import "PDMTriangle.h"

@interface View1 : UIView
{
    UIImage *image;
    float sx, sy;
    
    PDMShape *shape;
    NSArray *triangles;
}


- (void)setImage:(UIImage*)img;
- (void)setShape:(PDMShape*)s;
- (void)setTriangles:(NSArray*)tri;

@end
