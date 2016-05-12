//
//  CZJMyInfoRecordController.h
//  CZJShop
//
//  Created by Joe.Pen on 1/12/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJScanRecordMessageDelegate <NSObject>

- (void)clickOneRecordToMessage:(CZJMyScanRecordForm*)scanForm;

@end

@interface CZJMyInfoRecordController : CZJViewController
@property (strong, nonatomic) NSString* fromMessage;
@property (strong, nonatomic)NSString* storeId;
@property (weak, nonatomic) id<CZJScanRecordMessageDelegate> delegate;
@end
