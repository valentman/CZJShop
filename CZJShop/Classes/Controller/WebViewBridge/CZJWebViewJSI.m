//
//  CZJWebViewJSI.m
//  CZJShop
//
//  Created by Joe.Pen on 2/27/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJWebViewJSI.h"

@implementation CZJWebViewJSI

#pragma mark- JSAction

-(void)routeGuide:(NSArray *)routeGuide{
    NSString* ns1 = [routeGuide firstObject];
    NSDictionary* dict = [CZJUtils dictionaryFromJsonString:ns1];
    double lng = [[dict objectForKey:@"lng"] doubleValue];
    double lat = [[dict objectForKey:@"lat"] doubleValue];
    NSString* name = [dict objectForKey:@"name"];
    [self.JSIDelegate guidedSystemWithLng:lng
                                     Lat:lat
                                CityName:name];
    //    NSArray* array = [ns1 componentsSeparatedByString:@","];
    //    double lng = [[self CutString:[array objectAtIndex:0] Prefix:@"lng"] doubleValue];
    //    double lat = [[self CutString:[array objectAtIndex:1] Prefix:@"lat"] doubleValue];
    //    NSString* name = [self CutString:[array objectAtIndex:2] Prefix:@"name"];
    //    [self.JSDelegate  guidedSystemWithLng:lng Lat:lat CityName:name];
    //    DmLog(@"lng:%f , lat:%f name:%@",lng,lat,name);
}

-(void)moreComment:(NSArray *)comment{
    //    NSString* moreCommentId = [self CutString:[comment firstObject] Prefix:@"storeId"];
    //    moreCommentId = [moreCommentId stringByReplacingOccurrencesOfString:@":" withString:@""];
    //    moreCommentId = [moreCommentId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSData *jsonData = [[comment firstObject] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
    [self.JSIDelegate moreCommentActionWithId:dic];
}


-(void)call:(NSArray *)tel{
    
    NSString* tmp = [CZJUtils resetString:[tel firstObject]];
    NSLog(@"i be called:%@",tmp);
    [self.JSIDelegate callUp:tmp];
}

-(void)viewServiceItem:(NSArray *)item{
    NSString* itemId = [CZJUtils cutString:[item firstObject] Prefix:@"itemId"];
    NSLog(@"i be called:%@",itemId);
}

-(void)buy:(NSArray*)msg{
    NSString* ns1 = [CZJUtils resetString:[msg firstObject]];
    NSDictionary* dict = [CZJUtils dictionaryFromJsonString:ns1];
    [self.JSIDelegate buyWithInfo:dict];
}

-(void)setTitle:(NSArray*)msg{
    NSString* ns1 = [CZJUtils resetString:[msg firstObject]];
    [self.JSIDelegate setTitle:ns1];
}

-(void)showCarType:(NSArray*)cars{
    NSString* ns1 = [CZJUtils resetString:[cars firstObject]];
    NSLog(@"%@",ns1);
    [self.JSIDelegate showCarType:ns1];
}

-(void)showToast:(NSArray*)cars{
    NSString* ns1 = [CZJUtils resetString:[cars firstObject]];
    NSLog(@"%@",ns1);
    [self.JSIDelegate showToast:ns1];
    
}

- (void)toGoodsOrServiceInfo:(NSArray*)json
{
    NSString* ns1 = [CZJUtils resetString:[json firstObject]];
    NSLog(@"%@",ns1);
    [self.JSIDelegate showGoodsOrServiceInfo:ns1];
}

- (void)toStoreInfo:(NSArray*)json
{
    NSString* ns1 = [CZJUtils resetString:[json firstObject]];
    NSLog(@"%@",ns1);
    [self.JSIDelegate showStoreInfo:ns1];
}
- (void)jiesuan:(NSArray*)json andCount:(int)count
{
    NSString* ns1 = [CZJUtils resetString:[json firstObject]];
    NSLog(@"%@",ns1);
    [self.JSIDelegate toSettleOrder:ns1 andCount:count];
}

@end
