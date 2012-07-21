//
//  View1.m
//  PAWBenchmark
//
//  Created by DINA BURRI on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "View1.h"

@implementation View1

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setImage:(UIImage*)img
{
    CGSize viewSize = self.frame.size;
    
    sx = viewSize.width/img.size.width;
    sy = viewSize.height/img.size.height;
    
    CGSize imgSize = CGSizeMake(sx*img.size.width, sy*img.size.height);
    
    UIGraphicsBeginImageContext(imgSize);
    [img drawInRect:CGRectMake(0, 0, viewSize.width, viewSize.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


- (void)setShape:(PDMShape*)s
{
    shape = s;
}


- (void)setTriangles:(NSArray*)tri
{
    triangles = tri;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGRect imgRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:imgRect];
    
    if(shape)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
     
        
        
        
        if(triangles)
        {
            CGContextSetLineWidth(context, 3.0f);
            CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
            CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
            for(int i = 0; i < [triangles count]; ++i)
            {
                PDMTriangle *tri = [triangles objectAtIndex:i];
                CGPoint p1 = CGPointMake(shape.shape[tri.index[0]].pos[0]*sx, shape.shape[tri.index[0]].pos[1]*sy);
                CGPoint p2 = CGPointMake(shape.shape[tri.index[1]].pos[0]*sx, shape.shape[tri.index[1]].pos[1]*sy);
                CGPoint p3 = CGPointMake(shape.shape[tri.index[2]].pos[0]*sx, shape.shape[tri.index[2]].pos[1]*sy);
                
                CGContextMoveToPoint(context, p1.x, p1.y);
                CGContextAddLineToPoint(context, p2.x, p2.y);
                CGContextAddLineToPoint(context, p3.x, p3.y);
                CGContextAddLineToPoint(context, p1.x, p1.y);
                CGContextClosePath(context);
                CGContextDrawPath(context, kCGPathStroke);
            }
        }
        
        
        CGContextSetLineWidth(context, 3.0f);
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
        for(int i = 0; i < shape.num_points; ++i)
        {
            CGPoint p = CGPointMake(shape.shape[i].pos[0]*sx, shape.shape[i].pos[1]*sy);
            CGContextFillEllipseInRect(context, CGRectMake(p.x-5, p.y-5, 10, 10));
        }
        

    }
    
    
}


@end
