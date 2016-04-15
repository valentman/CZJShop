//
//  CZJChoosedProductCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/25/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJGoodsDetailForm.h"
@interface CZJChoosedProductCell : UITableViewCell
@property (strong, nonatomic)NSIndexPath* indexPath;
@property (strong, nonatomic)NSString* storeItemPid;
@property (strong, nonatomic)CZJGoodsDetail* goodsDetail;
@property (strong, nonatomic)NSString* counterKey;

@property (weak, nonatomic) IBOutlet UILabel *productType;
@end
