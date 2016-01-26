//
//  CZJAddMyCarController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/25/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJAddMyCarController.h"
#import "UIImageView+WebCache.h"
#import "CZJBaseDataManager.h"
#import "GKHpickerAddressView.h"
#import "CZJCarForm.h"
#import "CZJMyCarListController.h"

@interface CZJAddMyCarController ()
@property (weak, nonatomic) IBOutlet UIView *viewTwo;
@property (weak, nonatomic) IBOutlet UIView *viewOne;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewOneLayoutHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTwoLayoutWidth;
@property (weak, nonatomic) IBOutlet UIImageView *carBrandImg;
@property (weak, nonatomic) IBOutlet UILabel *carNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *carModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *carPlateNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *defBtn;
@property (weak, nonatomic) IBOutlet UITextField *plateNumTextField;

- (IBAction)setCarDefalutAction:(id)sender;

- (IBAction)addMyCarAction:(id)sender;
- (IBAction)chooseCarPlateNumAction:(id)sender;
@end

@implementation CZJAddMyCarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initDatas];
}

- (void)initViews
{
    [CZJUtils customizeNavigationBarForTarget:self];
    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
    self.viewOneLayoutHeight.constant = 0.3;
    self.viewTwoLayoutWidth.constant = 0.3;
    CGPoint pt = CGPointMake(self.carPlateNumLabel.origin.x + self.carPlateNumLabel.size.width, self.carPlateNumLabel.origin.y + self.carPlateNumLabel.size.height * 0.5);
    CAShapeLayer *indicator = [CZJUtils creatIndicatorWithColor:[UIColor blackColor] andPosition:pt];
    [self.viewTwo.layer addSublayer:indicator];
}

- (void)initDatas
{
    self.carNameLabel.text = [NSString stringWithFormat:@"%@ %@", CZJBaseDataInstance.carBrandForm.name,CZJBaseDataInstance.carSerialForm.name];
    self.carModelLabel.text = CZJBaseDataInstance.carModealForm.name;
    [self.carBrandImg sd_setImageWithURL:[NSURL URLWithString:CZJBaseDataInstance.carBrandForm.icon] placeholderImage:[UIImage imageNamed:@"default_icon_car"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)setCarDefalutAction:(id)sender
{
    self.defBtn.selected = !self.defBtn.selected;
}

- (IBAction)addMyCarAction:(id)sender
{
    NSMutableDictionary* carInfo = [@{ @"brandId": CZJBaseDataInstance.carBrandForm.brandId,
                                       @"brandName": CZJBaseDataInstance.carBrandForm.name,
                                       @"seriesId": [NSString stringWithFormat:@"%d",CZJBaseDataInstance.carSerialForm.seriesId],
                                       @"seriesName": CZJBaseDataInstance.carSerialForm.name,
                                       @"modelId": CZJBaseDataInstance.carModealForm.modelId,
                                       @"modelName" : CZJBaseDataInstance.carModealForm.name,
                                       @"numberPlate" : self.plateNumTextField.text,
                                       @"prov": @"川",
                                       @"number" : @"L",
                                       @"logo" : CZJBaseDataInstance.carBrandForm.icon,
                                       @"dftFlag" : [NSNumber numberWithBool: self.defBtn.selected]
                                       } mutableCopy];
    [CZJBaseDataInstance addMyCar:@{@"paramJson":[CZJUtils JsonFromData:carInfo]} Success:^(id json) {
        [CZJUtils tipWithText:@"添加成功" andView:nil];
        NSArray* vcs = self.navigationController.viewControllers;
        for (id controller in vcs)
        {
            if ([controller isKindOfClass:[CZJMyCarListController class]])
            {
                [self.navigationController popToViewController:controller animated:true];
                break;
            }
        }
    } fail:^{
        
    }];
}

- (IBAction)chooseCarPlateNumAction:(id)sender
{
    [GKHpickerAddressView shareInstancePickerAddressByctrl:self block:^(UIViewController *ctrl, NSString *addressName) {

    }];
}
@end
