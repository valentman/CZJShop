//
//  CZJNetworkManager.h
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface CZJNetworkManager : AFHTTPSessionManager
{    
}

singleton_interface(CZJNetworkManager)

- (void)checkNetWorkStatus;

- (void)JSONDataWithUrl:(NSString *)url
                success:(void (^)(id json))success
                   fail:(void (^)())fail;

- (void)postJSONWithNoServerAPI:(NSString *)urlStr
                     parameters:(id)parameters
                        success:(void (^)(id responseObject))success
                           fail:(void (^)())fail;

- (void)postJSONWithUrl:(NSString *)urlStr
             parameters:(id)parameters
                success:(void (^)(id responseObject))success
                   fail:(void (^)())fail;

- (void)postJSONWithParameters:(id)parameters
                       success:(void (^)(id))success
                          fail:(void (^)())fail;

- (void)sessionDownloadWithUrl:(NSString *)urlStr
                       success:(void (^)(NSURL *fileURL))success
                          fail:(void (^)())fail;

- (void)loadImagePath:(NSString*)path
             callback:(void (^)(id responseObject))callfun;

- (void)uploadImageWithUrl:(NSString *)urlStr
                     Image:(UIImage *)image
                Parameters:(id)parameters
                   success:(void (^)(id json))success
                   failure:(void (^)())failure;

- (void)saveImage:(UIImage *)image withFilename:(NSString *)filename;
@end
