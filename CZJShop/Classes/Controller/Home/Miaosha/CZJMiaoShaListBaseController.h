//
//  CZJMiaoShaListBaseController.h
//  CZJShop
//
//  Created by Joe.Pen on 3/10/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJMiaoShaListDelegate <NSObject>

- (void)clickMiaoShaCell:(CZJMiaoShaCellForm*)cellForm;

@end

@interface CZJMiaoShaListBaseController : CZJViewController
{
    NSDictionary* _params;
}
@property (strong, nonatomic)NSDictionary* params;
@property (strong, nonatomic)CZJMiaoShaTimesForm* miaoShaTimes;    //秒杀场次
@property (weak, nonatomic)id<CZJMiaoShaListDelegate> delegate;

- (void)getMiaoShaDataFromServer;
@end

@interface CZJMiaoShaOneController : CZJMiaoShaListBaseController
@end

@interface CZJMiaoShaTwoController : CZJMiaoShaListBaseController
@end

@interface CZJMiaoShaThreeController : CZJMiaoShaListBaseController
@end

@interface CZJMiaoShaFourController : CZJMiaoShaListBaseController
@end

@interface CZJMiaoShaFiveController : CZJMiaoShaListBaseController
@end