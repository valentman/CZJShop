//
//  CZJCustomAnnotationView.m
//  CZJShop
//
//  Created by Joe.Pen on 12/7/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJCustomAnnotationView.h"
#import "CZJStoreForm.h"

#define kCalloutWidth       200.0
#define kCalloutHeight      70.0

@implementation CZJCustomAnnotationView

-(void)setJzAnnotation:(CZJMAAroundAnnotation *)jzAnnotation{
    _jzAnnotation = jzAnnotation;
}


- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

//重写此函数,⽤用以实现点击calloutView判断为点击该annotationView
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL inside = [super pointInside:point withEvent:event];
    if (!inside && self.selected) {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    return inside;
}

@end
