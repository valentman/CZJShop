//
//  CZJCustomAnnotationView.m
//  CZJShop
//
//  Created by Joe.Pen on 12/7/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJCustomAnnotationView.h"
#import "UIImageView+WebCache.h"
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
    if (self.selected == selected) {
        return;
    }
    
    if (selected) {
        if (self.calloutView == nil) {
            self.calloutView = [[CZJCustomCallOutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            //            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds)/2.f+self.calloutOffset.x, -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
        }
        
        //        self.calloutView.image = [UIImage imageNamed:@"bg_customReview_image_default"];
        //        NSString *imgUrl = [_jzAnnotation.jzmaaroundM.imgurl stringByReplacingOccurrencesOfString:@"w.h" withString:@"104.63"];
        NSString *imgUrl = _jzAnnotation.jzmaaroundM.homeImg;
        [self.calloutView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"default_icon_shop-.png"]];
        self.calloutView.title = self.annotation.title;
        self.calloutView.subtitle = self.annotation.subtitle;
        self.calloutView.thrtitle = self.jzAnnotation.thrtitle;
        self.calloutView.storekey = self.jzAnnotation.jzmaaroundM.storeId;
        [self addSubview:self.calloutView];
    }else{
        [self.calloutView removeFromSuperview];
    }
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
