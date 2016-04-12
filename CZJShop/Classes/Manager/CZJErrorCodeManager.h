//
//  CZJErrorCodeManager.h
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDAlertView.h"

@interface CZJErrorCodeManager : NSObject
{
    NSDictionary * _errorInfoDictionary;
    NSDictionary * _errorTypeDictionary;
}
singleton_interface(CZJErrorCodeManager)
-(void)ShowErrorInfoWithErrorCode:(NSString *)errorCode;
- (void)ShowNetError;

@end
