//
//  CZJCarSeriesChooseController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/11/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJFilterBaseController.h"
#import "CZJCarForm.h"

@interface CZJCarSeriesChooseController : CZJFilterBaseController
{
    NSMutableDictionary* _carSes;
    NSArray * _keys;
    id _currentSelect;
}
@property(nonatomic,retain)CarBrandsForm *carBrand;

@end
