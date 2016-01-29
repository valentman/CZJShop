//
//  CZJOrderForm.h
//  CZJShop
//
//  Created by Joe.Pen on 1/7/16.
//  Copyright © 2016 JoeP. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface CZJOrderForm : NSObject
@property(strong, nonatomic)NSString* cardMoney;
@property(strong, nonatomic)NSString* needAddr;
@property(strong, nonatomic)NSString* needCoupon;
@property(strong, nonatomic)NSString* needRedpacket;
@property(strong, nonatomic)NSString* redpacket;
@property(strong, nonatomic)NSMutableArray* stores;

- (id) initWithDictionary:(NSDictionary*)dict;
@end

@interface CZJOrderStoreForm : NSObject
@property(strong, nonatomic)NSMutableArray* gifts;              //赠品
@property(strong, nonatomic)NSMutableArray* items;              //商品
@property(strong, nonatomic)NSString* fullCutPrice;             //满减
@property(strong, nonatomic)NSString* storeId;                  //门店ID
@property(strong, nonatomic)NSString* storeName;                //门店名字
@property(strong, nonatomic)NSString* transportPrice;           //运费
@property(strong, nonatomic)NSString* note;             //留言
@property(strong, nonatomic)NSString* companyId;                //
@property(strong, nonatomic)NSString* couponPrice;              //优惠券面值
@property(strong, nonatomic)NSString* chezhuCouponPid;
@property(strong, nonatomic)NSString* orderPrice;               //订单金额
@property(strong, nonatomic)NSString* orderMoney;               //实付金额
@property(strong, nonatomic)NSString* totalSetupPrice;          //总计的安装费用
@property(assign)BOOL selfFlag;                                 //是否是自营
@property(assign)BOOL hasCoupon;                                //是否可以领取优惠券

- (id) initWithDictionary:(NSDictionary*)dict;
@end


@interface CZJOrderListForm : NSObject
@property(strong, nonatomic)NSString* companyId;
@property(assign, nonatomic)BOOL evaluated;
@property(strong, nonatomic)NSMutableArray* items;
@property(strong, nonatomic)NSString* orderMoney;
@property(strong, nonatomic)NSString* orderNo;
@property(strong, nonatomic)NSString* status;
@property(assign, nonatomic)BOOL paidFlag;
@property(strong, nonatomic)NSString* storeId;
@property(strong, nonatomic)NSString* storeName;
@property(strong, nonatomic)NSString* type;
@end

@interface CZJOrderGoodsForm : NSObject
@property(strong, nonatomic)NSString* activityId;               //活动ID
@property(strong, nonatomic)NSString* costPrice;                //成本价
@property(strong, nonatomic)NSString* currentPrice;             //商品价格
@property(strong, nonatomic)NSString* itemCode;                 //商品编码
@property(strong, nonatomic)NSString* itemCount;                //商品数量
@property(strong, nonatomic)NSString* itemImg;                  //商品图片
@property(strong, nonatomic)NSString* itemName;                 //商品名字
@property(strong, nonatomic)NSString* itemSku;
@property(strong, nonatomic)NSString* itemType;                 //0商品 1 服务
@property(strong, nonatomic)NSString* storeItemPid;
@property(assign)BOOL setupFlag;                                //是否到店安装
@property(assign)BOOL setmenuFlag;                              //是否是套餐
@property(assign)BOOL off;                                      //是否已下架
@property(strong, nonatomic)NSString* typeId;
@property(strong, nonatomic)NSString* vendorId;                 //供应商ID
@property(strong, nonatomic)NSString* selectdSetupStoreName;    //安装门店名字
@property(strong, nonatomic)NSString* setupStoreId;             //安装门店ID
@property(strong, nonatomic)NSString* returnStatus;             //1等待卖家同意  2卖家已同意，请寄回商品 3等待卖家收货 4退换货成功
@property(strong, nonatomic)NSString* setupPrice;               //安装费
@property(strong, nonatomic)NSString* orderItemPid;

@end

@interface CZJOrderTypeForm : NSObject
@property(strong, nonatomic)NSString* orderTypeName;
@property(strong, nonatomic)NSString* orderTypeImg;
@property(assign) BOOL isSelect;
@end

@interface CZJAddrForm : NSObject
@property (strong, nonatomic)NSString* receiver;
@property (strong, nonatomic)NSString* province;
@property (strong, nonatomic)NSString* city;
@property (strong, nonatomic)NSString* county;
@property (assign) BOOL dftFlag;
@property (assign) BOOL isSelected;
@property (strong, nonatomic)NSString* mobile;
@property (strong, nonatomic)NSString* addr;
@property (strong, nonatomic)NSString* addrId;
@end

@interface CZJOrderStoreCouponsForm : NSObject
@property (strong, nonatomic)NSMutableArray* coupons;
@property (strong, nonatomic)NSString* storeId;
@property (strong, nonatomic)NSString* storeName;
@property (strong, nonatomic)NSString* selectedCouponId;
@property (assign) BOOL isSelfFlag;
@end
