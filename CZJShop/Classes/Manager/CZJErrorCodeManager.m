//
//  CZJErrorCodeManager.m
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJErrorCodeManager.h"

@interface CZJErrorCodeManager ()<FDAlertViewDelegate>

@end

@implementation CZJErrorCodeManager
singleton_implementation(CZJErrorCodeManager)

-(id)init
{
    if(self = [super init]){
        return self;
    }
    return  nil;
}

-(void)getErrorDictionary
{
    NSString * errorDescPath = [[NSBundle mainBundle] pathForResource:@"errorInfo" ofType:@"plist"];
    NSString * errorTypePath =  [[NSBundle mainBundle] pathForResource:@"errortype" ofType:@"plist"];
    
    _errorInfoDictionary = [[NSDictionary alloc] initWithContentsOfFile:errorDescPath];
    _errorTypeDictionary =  [[NSDictionary alloc] initWithContentsOfFile:errorTypePath];
}

-(void)ShowErrorInfoWithErrorCode:(NSString *)errorCode
{
    NSString * errorDescription;
    NSString * errorType;
    [self getErrorDictionary];
    
    if([_errorInfoDictionary objectForKey:errorCode]){
        errorDescription = [_errorInfoDictionary valueForKey:errorCode];
    }
    if ([_errorTypeDictionary  objectForKey:errorCode]) {
        errorType = [ _errorTypeDictionary valueForKey:errorCode];
    }
    
    
    if ([errorType  isEqualToString:@"1"]) {
        [self showErrorWranAsSheetWithError:errorDescription ];
    }else
    {
        [self showErrorDescriptionWithError:errorDescription];
    }
}

-(void)showErrorWranAsSheetWithError:(NSString *)Error
{
    FDAlertView *alert = [[FDAlertView alloc] initWithTitle:kCZJTitle icon:nil message:Error delegate:self buttonTitles:kCZJConfirmTitle,nil];
    [alert setMessageColor:[UIColor redColor] fontSize:0];
    [alert show];
}

-(void)showErrorDescriptionWithError:(NSString *)Error
{
    
}

- (void)alertView:(FDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%ld", (long)buttonIndex);
}

- (void)ShowNetError{
    FDAlertView *alert = [[FDAlertView alloc] initWithTitle:kCZJTitle icon:nil message:kCZJMessageNet delegate:self buttonTitles:kCZJConfirmTitle,nil];
    [alert setMessageColor:[UIColor redColor] fontSize:0];
    [alert setTag:9010];
    UIView* view = VIEWWITHTAG([[UIApplication sharedApplication] keyWindow], 9010);
    if (view == nil)
    {
        [alert show];
    }
    
}


@end
