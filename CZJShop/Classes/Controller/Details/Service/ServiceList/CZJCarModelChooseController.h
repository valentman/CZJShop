//
//  CZJCarModelChooseController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/11/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJFilterBaseController.h"
#import "CZJCarForm.h"

@interface CZJCarModelChooseController : CZJFilterBaseController
{
    NSMutableArray* _carModels;
    CarModelForm* _currentSelect;
}
@property(nonatomic,retain)CarBrandsForm* carBrand;
@property(nonatomic,retain)CarSeriesForm* carSeries;

@end
