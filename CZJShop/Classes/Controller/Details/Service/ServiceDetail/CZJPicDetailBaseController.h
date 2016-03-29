//
//  CZJPicDetailBaseController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/29/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJPicDetailBaseController : UIViewController
@property (nonatomic, assign)CZJDetailType detaiViewType;
@property (nonatomic, strong)NSString* detailUrl;
- (void)loadWebPageWithString:(NSString*)urlString;
@end


@interface CZJPicDetailController : CZJPicDetailBaseController
@end


@interface CZJBuyNoticeController : CZJPicDetailBaseController
@end


@interface CZJAfterServiceController : CZJPicDetailBaseController
@end


@interface CZJApplicableCarController : CZJPicDetailBaseController
@end
