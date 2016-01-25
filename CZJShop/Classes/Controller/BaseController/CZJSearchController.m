//
//  CZJSearchController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/25/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJSearchController.h"
#import "NIDropDown.h"

@interface CZJSearchController ()
<
NIDropDownDelegate,
UIGestureRecognizerDelegate,
UITextFieldDelegate
>
{
    NIDropDown *dropDown;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIView *clearHisView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

- (IBAction)cancelSerchAction:(id)sender;
- (IBAction)clearHistoryAction:(id)sender;
- (IBAction)chooseCategoryAction:(id)sender;

@end

@implementation CZJSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    // Do any additional setup after loading the view.
}

- (void)initViews
{
    self.searchView.layer.borderColor = RGB(240, 240, 240).CGColor;
    self.searchView.layer.borderWidth = 0.5;
    self.searchView.clipsToBounds = YES;
    CGPoint pt = CGPointMake(self.categoryLabel.origin.x + self.categoryLabel.size.width, self.categoryLabel.origin.y + self.categoryLabel.size.height * 0.5);
    CAShapeLayer *indicator = [CZJUtils creatIndicatorWithColor:[UIColor grayColor] andPosition:pt];
    [self.searchView.layer addSublayer:indicator];
    
    //背景触摸层
    _backgroundView.backgroundColor = RGBA(100, 240, 240, 0);
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [_backgroundView addGestureRecognizer:gesture];
    _backgroundView.hidden = YES;

    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
    self.myTableView.tableFooterView = [[UIView alloc] init];
    self.myTableView.hidden = YES;
    
    self.clearHisView.hidden = YES;
    
    self.categoryLabel.text = @"服务";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- NIDropDownDelegate
- (void) niDropDownDelegateMethod:(NSString*)btnStr
{
    if ([btnStr isEqualToString:@"服务"])
    {
        DLog(@"服务");
    }
    if ([btnStr isEqualToString:@"商品"])
    {
        DLog(@"商品");
    }
    if ([btnStr isEqualToString:@"门店"])
    {
        DLog(@"门店");
    }
    self.categoryLabel.text = btnStr;
    [self tapBackground:nil];
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

- (IBAction)cancelSerchAction:(id)sender
{
}

- (IBAction)clearHistoryAction:(id)sender
{
}

- (IBAction)chooseCategoryAction:(id)sender
{
    NSArray * arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@{@"服务" : @"shop_icon_serve"}, @{@"商品":@"shop_icon_goods"}, @{@"门店" :@"prodetail_icon_shop02"},nil];
    if(dropDown == nil) {
        CGRect rect = CGRectMake(15, StatusBar_HEIGHT + 68, 120, 150);
        _backgroundView.hidden = NO;
        dropDown = [[NIDropDown alloc]showDropDown:_backgroundView Frame:rect WithObjects:arr];
        dropDown.delegate = self;
    }
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}
@end
