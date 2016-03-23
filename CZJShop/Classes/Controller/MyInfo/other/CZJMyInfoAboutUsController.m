//
//  CZJMyInfoAboutUsController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/16/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyInfoAboutUsController.h"

@interface CZJMyInfoAboutUsController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logonTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *erweimaTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *erweimaWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descTop;

@end

@implementation CZJMyInfoAboutUsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    if ( iPhone5)
    {
        self.logonTop.constant = 50;
        self.erweimaTop.constant = 50;
        self.erweimaWidth.constant = 160;
        self.logonWidth.constant = 180;
    }
    if (iPhone4)
    {
        self.descTop.constant =20;
        self.logonTop.constant = 30;
        self.erweimaTop.constant = 30;
        self.erweimaWidth.constant = 160;
        self.logonWidth.constant = 180;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
