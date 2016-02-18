//
//  CZJHomeViewController.h
//  CZJShop
//
//  Created by Joe.Pen on 11/17/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJHomeViewController : CZJViewController
{
    NSMutableArray* _activityArray;  //活动数据
    NSMutableArray* _serviceArray;   //服务列表
    NSMutableArray* _carInfoArray;   //汽车资讯
    NSMutableArray* _miaoShaArray;   //秒杀数据
    NSMutableArray* _bannerOneArray;   //广告条
    NSMutableArray* _limitBuyArray;  //限量抢购数据
    NSMutableArray* _brandRecommentArray;  //品牌推荐数据
    NSMutableArray* _bannerTwoArray;    //第二个广告条
    NSMutableArray* _specialRecommentArray; //特别推荐数据
    NSMutableArray* _goodsRecommentArray;    //商品推荐数据
    
    NSString* _curSeviceType; /***<-当前选择的服务类型*/
    NSString* _curSeviceName;
    NSString* _webViewTitle;
    
    UIView* _errorView;
    BOOL _isRefresh;
    
    UISearchBar* customSearchBar;
    UIButton* btnScan;
    UIButton* btnShop;
}
@property (strong, nonatomic)NSString* recommandId;
@property (nonatomic,retain)NSString* curUrl;
@property (nonatomic, assign)EWebHtmlType htmlType;
@property (nonatomic, assign)BOOL isFirst;
@property (nonatomic, assign)BOOL isJumpToAnotherView;
@property (nonatomic,assign)int page;
@end
