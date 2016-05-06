//
//  CZJOrderForm.h
//  CZJShop
//
//  Created by Joe.Pen on 1/7/16.
//  Copyright © 2016 JoeP. All rights reserved.
//
#import <Foundation/Foundation.h>

@class CZJOrderDetailBuildForm;
@class CZJCarDetailForm;

@interface CZJOrderForm : NSObject
@property(strong, nonatomic)NSString* cardMoney;
@property(strong, nonatomic)NSString* needAddr;
@property(strong, nonatomic)NSString* needCoupon;
@property(strong, nonatomic)NSString* needRedpacket;
@property(strong, nonatomic)NSString* redpacket;
@property(strong, nonatomic)NSArray* stores;

@end

@interface CZJOrderStoreForm : NSObject
@property(strong, nonatomic)NSMutableArray* gifts;              //赠品
@property(strong, nonatomic)NSMutableArray* items;              //商品
@property(strong, nonatomic)NSString* fullCutPrice;             //满减
@property(strong, nonatomic)NSString* storeId;                  //门店ID
@property(strong, nonatomic)NSString* storeName;                //门店名字
@property(strong, nonatomic)NSString* transportPrice;           //运费
@property(strong, nonatomic)NSString* transportFree;            //满多少免运费
@property(strong, nonatomic)NSString* note;                     //留言
@property(strong, nonatomic)NSString* companyId;                //
@property(strong, nonatomic)NSString* couponPrice;              //优惠券面值
@property(strong, nonatomic)NSString* chezhuCouponPid;
@property(strong, nonatomic)NSString* orderPrice;               //订单金额
@property(strong, nonatomic)NSString* orderMoney;               //实付金额
@property(strong, nonatomic)NSString* totalSetupPrice;          //总计的安装费用
@property(assign)BOOL selfFlag;                                 //是否是自营
@property(assign)BOOL hasCoupon;                                //是否可以领取优惠券
- (id) init;
@end


@interface CZJOrderListForm : NSObject
@property(strong, nonatomic)NSString* companyId;
@property(strong, nonatomic)NSString* createTime;
@property(assign, nonatomic)BOOL evaluated;
@property(strong, nonatomic)NSMutableArray* items;
@property(strong, nonatomic)NSString* orderMoney;
@property(strong, nonatomic)NSString* orderNo;
@property(strong, nonatomic)NSString* status;
@property(assign, nonatomic)BOOL paidFlag;
@property(assign, nonatomic)BOOL onlineFlag;
@property(assign, nonatomic)BOOL isSelected;
@property(strong, nonatomic)NSString* storeId;
@property(strong, nonatomic)NSString* storeName;
@property(strong, nonatomic)NSString* type;
@end

@interface CZJOrderGoodsForm : NSObject
@property(strong, nonatomic)NSString* skillId;                  //秒杀场点ID
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
@property(assign)BOOL vendorFlag;
@property(strong, nonatomic)NSString* typeId;
@property(strong, nonatomic)NSString* vendorId;                 //供应商ID
@property(strong, nonatomic)NSString* selectdSetupStoreName;    //安装门店名字
@property(strong, nonatomic)NSString* setupStoreName;           //安装门店名字
@property(strong, nonatomic)NSString* setupStoreId;             //安装门店ID
@property(strong, nonatomic)NSString* returnStatus;             //1等待卖家同意  2卖家已同意，请寄回商品 3等待卖家收货 4退换货成功
@property(strong, nonatomic)NSString* setupPrice;               //安装费
@property(strong, nonatomic)NSString* orderItemPid;
@property(strong, nonatomic)NSString* counterKey;               //


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


@interface CZJOrderDetailForm : NSObject
@property (strong, nonatomic)NSString*  activityId;
@property (strong, nonatomic)NSString*  benefitMoney;
@property (strong, nonatomic)CZJOrderDetailBuildForm* build;
@property (strong, nonatomic)NSString*  companyId;
@property (strong, nonatomic)NSString*  couponPrice;
@property (strong, nonatomic)NSString*  createTime;
@property (assign, nonatomic)BOOL  evaluated;
@property (strong, nonatomic)NSString*  fullCutPrice;
@property (strong, nonatomic)NSMutableArray*  items;
@property (strong, nonatomic)NSMutableArray*  gifts;
@property (strong, nonatomic)NSString*  note;
@property (strong, nonatomic)NSString*  orderMoney;
@property (strong, nonatomic)NSString*  orderNo;
@property (strong, nonatomic)NSString*  orderPoint;
@property (strong, nonatomic)NSString*  orderPrice;
@property (assign, nonatomic)BOOL  paidFlag;
@property (strong, nonatomic)CZJAddrForm*  receiver;
@property (assign, nonatomic)BOOL  returnFlag;
@property (strong, nonatomic)NSString*  setupPrice;
@property (strong, nonatomic)NSString*  status;
@property (strong, nonatomic)NSString*  storeId;
@property (strong, nonatomic)NSString*  storeName;
@property (strong, nonatomic)NSString*  timeOver;
@property (strong, nonatomic)NSString*  transportPrice;
@property (strong, nonatomic)NSString*  type;
@property (strong, nonatomic)NSString* counterKey;
@end


#pragma mark- CarCheck
@interface CZJOrderDetailBuildForm : NSObject
@property (strong, nonatomic)NSString* builder;
@property (strong, nonatomic)CZJCarDetailForm* car;
@property (strong, nonatomic)NSString* head;
@property (strong, nonatomic)NSArray* photos;
@property (strong, nonatomic)NSString* useTime;
@end


@interface CZJCarDetailForm : NSObject
@property (strong, nonatomic)NSString* brandName;
@property (strong, nonatomic)NSString* modelName;
@property (strong, nonatomic)NSString* numberPlate;
@property (strong, nonatomic)NSString* seriesName;
@end

@interface CZJCarCheckItemForm : NSObject
@property (strong, nonatomic)NSString* checkItem;
@property (strong, nonatomic)NSString* checkResult;
@property (strong, nonatomic)NSString* note;
@end

@interface CZJCarCheckItemsForm : NSObject
@property (strong, nonatomic)NSString* checkType;
@property (strong, nonatomic)NSMutableArray* items;
@end

@interface CZJCarCheckForm : NSObject
@property (strong, nonatomic)CZJCarDetailForm* car;
@property (strong, nonatomic)NSString* checkNote;
@property (strong, nonatomic)NSMutableArray* checks;
@property (strong, nonatomic)NSMutableArray* photos;
@end

@interface CZJReturnedOrderListForm : NSObject
@property (strong, nonatomic)NSString* currentPrice;
@property (strong, nonatomic)NSString* itemCount;
@property (strong, nonatomic)NSString* itemImg;
@property (strong, nonatomic)NSString* itemName;
@property (strong, nonatomic)NSString* itemSku;
@property (strong, nonatomic)NSString* orderItemPid;
@property (strong, nonatomic)NSString* returnStatus;
@end

@interface CZJReturnedOrderDetailForm : NSObject
@property (strong, nonatomic)NSString* contactAccount;
@property (strong, nonatomic)NSString* contactName;
@property (strong, nonatomic)NSString* logo;
@property (strong, nonatomic)NSString* orderItemPid;
@property (strong, nonatomic)NSString* orderNo;
@property (strong, nonatomic)NSArray* returnImgs;
@property (strong, nonatomic)NSString* returnMoney;
@property (strong, nonatomic)NSString* returnNote;
@property (strong, nonatomic)NSString* returnReason;
@property (strong, nonatomic)NSString* returnStatus;
@property (strong, nonatomic)NSString* returnTime;
@property (strong, nonatomic)NSString* returnType;   //1为退货，其他为换货
@end


@interface CZJSubmitReturnForm : NSObject
@property (strong, nonatomic)NSString* returnType;
@property (strong, nonatomic)NSString* returnNote;
@property (strong, nonatomic)NSString* orderItemPid;
@property (strong, nonatomic)NSString* returnReason;
@property (strong, nonatomic)NSString* returnImgs;
@end
