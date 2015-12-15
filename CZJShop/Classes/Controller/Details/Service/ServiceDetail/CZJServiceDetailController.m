//
//  CZJServiceDetailController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/14/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJServiceDetailController.h"
#import "CZJNaviagtionBarView.h"
#import "NIDropDown.h"
#import "CZJBaseDataManager.h"
@interface CZJServiceDetailController ()<NIDropDownDelegate>
{
    NIDropDown *dropDown;
}
@property (weak, nonatomic) IBOutlet UIView *borderLineView;
@property (weak, nonatomic) IBOutlet CZJNaviagtionBarView *detailNaviBarView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation CZJServiceDetailController
@synthesize storeItemPid = _storeItemPid;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    
}

- (void)initViews
{
    self.borderLineView.layer.borderWidth = 0.1;
    self.borderLineView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //顶部导航栏
    CGRect mainViewBounds = self.navigationController.navigationBar.bounds;
    CGRect viewBounds = CGRectMake(0, 0, mainViewBounds.size.width, 52);
    [self.detailNaviBarView initWithFrame:viewBounds AndType:CZJViewTypeNaviBarViewDetail].delegate = self;
    [self.detailNaviBarView setBackgroundColor:[UIColor clearColor]];
    
    //背景触摸层
    _backgroundView.backgroundColor = RGBACOLOR(100, 240, 240, 0);
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [_backgroundView addGestureRecognizer:gesture];
    _backgroundView.hidden = YES;
    
    
}

- (void)getDataFromServer
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        
    };
    
    [CZJBaseDataInstance loadDetailsWithType:CZJDetailTypeService
                             AndStoreItemPid:self.storeItemPid
                                     Success:successBlock
                                        fail:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark- CZJNaviBarViewDelegate
- (void)clickEventCallBack:(id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarMore:
        {
            NSArray * arr = [[NSArray alloc] init];
            arr = [NSArray arrayWithObjects:@{@"消息" : @"prodetail_icon_msg"}, @{@"首页":@"prodetail_icon_home"}, @{@"分享" :@"prodetail_icon_share"},nil];
            if(dropDown == nil) {
                CGRect rect = CGRectMake(PJ_SCREEN_WIDTH - 120 - 14, StatusBar_HEIGHT + 78, 120, 150);
                _backgroundView.hidden = NO;
                dropDown = [[NIDropDown alloc]showDropDown:_backgroundView Frame:rect WithObjects:arr];
                dropDown.delegate = self;
            }
        }
            break;
            
        case CZJButtonTypeNaviBarBack:
            [self.navigationController popViewControllerAnimated:true];
            break;
            
        case CZJButtonTypeHomeShopping:
            
            break;
            
        default:
            break;
    }
}

- (void)tapBackground:(UITapGestureRecognizer *)paramSender
{
    if (dropDown)
    {
        _backgroundView.hidden = YES;
        [dropDown hideDropDown:paramSender];
        dropDown = nil;
    }

}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete
{
    if (show) {
        [UIView animateWithDuration:0.5 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
        }];
    }
    complete();
    
}


#pragma mark- NIDropDownDelegate
- (void) niDropDownDelegateMethod:(NSString*)btnStr
{
    if ([btnStr isEqualToString:@"消息"])
    {
        DLog(@"消息");
    }
    if ([btnStr isEqualToString:@"首页"])
    {
        DLog(@"首页");
    }
    if ([btnStr isEqualToString:@"分享"])
    {
        DLog(@"分享");
    }
}

@end
