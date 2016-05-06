//
//  NIDropDown.m
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"

@interface NIDropDown ()
{
    CGRect myRect;
    CAShapeLayer* trangleLayer;
    CZJNIDropDownType dropDownType;
    NSArray* titleAry;
}
@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIButton *btnSender;
@property(nonatomic, retain) NSArray *list;
@end

@implementation NIDropDown
@synthesize table;
@synthesize btnSender;
@synthesize list;
@synthesize delegate;

- (id)showDropDown:(id)target Frame:(CGRect)rect WithObjects:(NSArray *)arr andType:(CZJNIDropDownType)_dropDownType{
    dropDownType = _dropDownType;
    btnSender = (UIButton*)target;
    myRect = rect;
    titleAry = arr;
    if (self = [super init]) {
        self.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 0);
        self.list = [NSArray arrayWithArray:arr];
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        table.delegate = self;
        table.dataSource = self;
        table.layer.cornerRadius = 2;
        table.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1];

        table.bounces = NO;
        [self addSubview:table];
        
        
        switch (dropDownType)
        {
            case CZJNIDropDownTypeCustomize:
                table.separatorStyle = UITableViewCellSeparatorStyleNone;
                break;
                
            case CZJNIDropDownTypeNormal:
                table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                table.separatorColor = [UIColor grayColor];
                
                self.layer.masksToBounds = NO;
                self.layer.shadowOffset = CGSizeMake(-1, 1);
                self.layer.shadowOpacity = 0.5;
                
                CGPoint tranglePoint = CGPointMake(table.frame.origin.x + rect.size.width - 16, table.frame.origin.y - 5);
                trangleLayer = [self creatIndicatorWithColor:[UIColor whiteColor] andPosition:tranglePoint];
                [self.layer addSublayer:trangleLayer];
                break;
                
            default:
                break;
        }


        
        
        
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
//        table.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        [UIView commitAnimations];
        
        [btnSender.superview addSubview:self];
        
    }
    return self;
}


- (CAShapeLayer *)creatIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point
{
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(8, 0)];
    [path addLineToPoint:CGPointMake(16, 10)];
    [path addLineToPoint:CGPointMake(0, 10)];
    [path closePath];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.fillColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    
    layer.position = point;
    
    return layer;
}

- (void)setTrangleLayerPositioin:(CZJLayerPositionType)pos
{
    CGPoint tranglePoint;
    switch (pos)
    {
        case kCZJLayerPositionTypeCenter:
            tranglePoint = CGPointMake(table.frame.origin.x + myRect.size.width*0.5 - 8, table.frame.origin.y - 5);
            break;
        case kCZJLayerPositionTypeLeft:
            tranglePoint = CGPointMake(table.frame.origin.x + 16, table.frame.origin.y - 5);
            break;
        case kCZJLayerPositionTypeRight:
            tranglePoint = CGPointMake(table.frame.origin.x + myRect.size.width - 16, table.frame.origin.y - 5);
            break;
            
        default:
            break;
    }
    trangleLayer.position = tranglePoint;
}

-(void)hideDropDown:(id)b {
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = CGRectMake(myRect.origin.x, myRect.origin.y, myRect.size.width, 30);
        self.alpha = 0.2;
        table.frame = CGRectMake(0, 0, myRect.size.width, 0);
        CGRect fra = trangleLayer.frame;
        trangleLayer.frame = CGRectMake(fra.origin.x, fra.origin.y, fra.size.width, 0);
        [trangleLayer removeFromSuperlayer];
        trangleLayer = nil;
    } completion:^(BOOL finished) {
        if (finished) {
            [self retain];
            [self removeFromSuperview];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (dropDownType == CZJNIDropDownTypeCustomize)
    {
        return 40;
    }
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.list count];
}   


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = SYSTEMFONT(15);
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    NSDictionary* dict = [list objectAtIndex:indexPath.row];
    NSString* key = [[ dict allKeys] firstObject];
    cell.textLabel.text = key;
    cell.textLabel.textColor = [UIColor blackColor];
    [cell.imageView setImage:[UIImage imageNamed:[dict valueForKey:key]]];
    
    if (dropDownType == CZJNIDropDownTypeCustomize)
    {
        [cell.textLabel drawTextInRect:CGRectMake(15, 10, PJ_SCREEN_WIDTH - 60, 20)];
        cell.textLabel.textColor = RGB(192, 192, 192);
        cell.textLabel.font = SYSTEMFONT(13);
        if ([key isEqualToString:_data])
        {
            cell.textLabel.textColor = RGB(102, 102, 102);
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString* btnStr = cell.textLabel.text;
    [self.delegate niDropDownDelegateMethod:btnStr];
}

-(void)dealloc {
    [super dealloc];
    [table release];
    [self release];
}

@end
