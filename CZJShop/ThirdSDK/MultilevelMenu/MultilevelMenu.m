//
//  MultilevelMenu.m
//  MultilevelMenu
//
//  Created by gitBurning on 15/3/13.
//  Copyright (c) 2015年 BR. All rights reserved.
//

#import "MultilevelMenu.h"
#import "MultilevelTableViewCell.h"
#import "MultilevelCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "CZJHomeViewManager.h"
#import "AnimatedGif.h"
#import "CollectionHeader.h"

#define kImageDefaultName @"tempShop"
#define kMultilevelCollectionViewCell @"MultilevelCollectionViewCell"
#define kMultilevelCollectionHeader   @"CollectionHeader"//CollectionHeader
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface MultilevelMenu()

@property(strong,nonatomic ) UITableView * leftTablew;
@property(strong,nonatomic ) UICollectionView * rightCollection;

@property(assign,nonatomic) BOOL isReturnLastOffset;

@end
@implementation MultilevelMenu


-(id)initWithFrame:(CGRect)frame WithData:(NSArray *)data withSelectIndex:(void (^)(NSInteger, NSInteger, id))selectIndex
{
    
    if (self  == [super initWithFrame:frame]) {
        if (data.count==0) {
            return nil;
        }
        
        _block=selectIndex;
        self.leftSelectColor= RGB(240, 50, 50);
        self.leftSelectBgColor=[UIColor whiteColor];
        self.leftBgColor=UIColorFromRGB(0xF3F4F6);
        self.leftSeparatorColor=UIColorFromRGB(0xE5E5E5);
        self.leftUnSelectBgColor=UIColorFromRGB(0xF3F4F6);
        self.leftUnSelectColor=[UIColor blackColor];
        
        _selectIndex=1;
        _allData=data;
        
        /**
         左边的视图
        */
        self.leftTablew=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kLeftWidth, frame.size.height)];
        self.leftTablew.dataSource=self;
        self.leftTablew.delegate=self;
        self.leftTablew.showsVerticalScrollIndicator = NO;
        
        self.leftTablew.tableFooterView=[[UIView alloc] init];
        [self addSubview:self.leftTablew];
        self.leftTablew.backgroundColor=self.leftBgColor;
        if ([self.leftTablew respondsToSelector:@selector(setLayoutMargins:)]) {
            self.leftTablew.layoutMargins=UIEdgeInsetsZero;
        }
        if ([self.leftTablew respondsToSelector:@selector(setSeparatorInset:)]) {
            self.leftTablew.separatorInset=UIEdgeInsetsZero;
        }
        self.leftTablew.separatorColor=self.leftSeparatorColor;
        
        
        /**
         右边的视图
         */
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing=0.f;//左右间隔
        flowLayout.minimumLineSpacing=0.f;
        float leftMargin =0;
        self.rightCollection=[[UICollectionView alloc] initWithFrame:CGRectMake(kLeftWidth+leftMargin,0,kScreenWidth-kLeftWidth-leftMargin*2,frame.size.height) collectionViewLayout:flowLayout];
        
        self.rightCollection.delegate=self;
        self.rightCollection.dataSource=self;
        
        UINib *nib=[UINib nibWithNibName:kMultilevelCollectionViewCell bundle:nil];
        [self.rightCollection registerNib: nib forCellWithReuseIdentifier:kMultilevelCollectionViewCell];
        
        UINib *header=[UINib nibWithNibName:kMultilevelCollectionHeader bundle:nil];
        [self.rightCollection registerNib:header forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMultilevelCollectionHeader];
        
        [self addSubview:self.rightCollection];
        
        self.selelctIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        if (self.allData.count>0) {
            [self tableView:self.leftTablew didSelectRowAtIndexPath: self.selelctIndexPath];
        }
      
        self.isReturnLastOffset=YES;
        self.rightCollection.backgroundColor=self.leftSelectBgColor;
        self.backgroundColor=self.leftSelectBgColor;
        
    }
    return self;
}

-(void)setLeftBgColor:(UIColor *)leftBgColor{
    _leftBgColor=leftBgColor;
    self.leftTablew.backgroundColor=leftBgColor;
   
}
-(void)setLeftSelectBgColor:(UIColor *)leftSelectBgColor{
    
    _leftSelectBgColor=leftSelectBgColor;
    self.rightCollection.backgroundColor=leftSelectBgColor;
    
    self.backgroundColor=leftSelectBgColor;
}
-(void)setLeftSeparatorColor:(UIColor *)leftSeparatorColor{
    _leftSeparatorColor=leftSeparatorColor;
    self.leftTablew.separatorColor=leftSeparatorColor;
}
-(void)reloadData{
    
    [self.leftTablew reloadData];
    [self.rightCollection reloadData];
    
}
- (void)getCategoryDataFromServer:(NSString*)typeId
{
    //从服务器获取数据成功返回回调
    CZJSuccessBlock successBlock = ^(id json){
        NSDictionary* tempdata = [CZJUtils DataFromJson:json];
        DLog(@"%@",[tempdata description]);
        //分类数据信息
        NSArray* types = [[tempdata valueForKey:@"msg"] valueForKey:@"types"];
        rightMeun* tempMenu = self.allData[self.selectIndex];
        for (id dict in types) {
            rightMeun* menu = [[rightMeun alloc]init];
            menu.ID = [dict valueForKey:@"typeId"];
            menu.meunName = [dict valueForKey:@"name"];
            menu.urlName = [dict valueForKey:@"img"];
            [tempMenu.nextArray addObject:menu];
        }
        
        //广告栏信息
        NSDictionary* banners = [[tempdata valueForKey:@"msg"] valueForKey:@"banner"];
        BannerAdForm* bannerAd = tempMenu.bannerAd;
        bannerAd.target= banners[@"target"];
        bannerAd.typeID = banners[@"type"];
        bannerAd.img = banners[@"img"];
        [self.rightCollection reloadData];
    };
    
    CZJFailureBlock failBlock = ^{};
    
    [CZJHomeViewInstance showCategoryTypeId:typeId success:successBlock fail:failBlock];
}

#pragma mark---左边的tablew 代理
#pragma mark--deleagte
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * Identifier=@"MultilevelTableViewCell";
    MultilevelTableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    if (!cell) {
        cell=[[NSBundle mainBundle] loadNibNamed:@"MultilevelTableViewCell" owner:self options:nil][0];
        
        UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(kLeftWidth-0.5, 0, 0.5, 44)];
        label.backgroundColor=tableView.separatorColor;
        [cell addSubview:label];
        label.tag=100;
    }
    rightMeun * title=self.allData[indexPath.row];
    cell.titile.text=title.meunName;
    
    UILabel * line=(UILabel*)[cell viewWithTag:100];
    
    if (indexPath.row==self.selectIndex) {
        cell.titile.textColor=self.leftSelectColor;
        cell.backgroundColor=self.leftSelectBgColor;
        line.backgroundColor=cell.backgroundColor;
    }
    else{
        cell.titile.textColor=self.leftUnSelectColor;
        cell.backgroundColor=self.leftUnSelectBgColor;
        line.backgroundColor=tableView.separatorColor;
    }

    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins=UIEdgeInsetsZero;
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset=UIEdgeInsetsZero;
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectIndex == 0)
    {
        [self tableView:tableView didDeselectRowAtIndexPath:self.selelctIndexPath];
    }
    MultilevelTableViewCell * cell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.titile.textColor=self.leftSelectColor;
    cell.backgroundColor=self.leftSelectBgColor;
    self.selectIndex = indexPath.row;
    cell.selected = YES;
    rightMeun * title=self.allData[indexPath.row];
    NSString* typeID = title.ID;
    NSArray* nextAry = title.nextArray;

    UILabel * line=(UILabel*)[cell viewWithTag:100];
    line.backgroundColor=cell.backgroundColor;

    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    self.isReturnLastOffset=NO;
    
    if (self.isRecordLastScroll) {
        [self.rightCollection scrollRectToVisible:CGRectMake(0, title.offsetScorller, self.rightCollection.frame.size.width, self.rightCollection.frame.size.height) animated:NO];
    }
    else{
        
         [self.rightCollection scrollRectToVisible:CGRectMake(0, 0, self.rightCollection.frame.size.width, self.rightCollection.frame.size.height) animated:NO];
    }
    
    if (nextAry.count <= 0) {
        [self getCategoryDataFromServer:typeID];
    }
    else
    {
        [self.rightCollection reloadData];
    }
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MultilevelTableViewCell * cell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.titile.textColor=self.leftUnSelectColor;
    UILabel * line=(UILabel*)[cell viewWithTag:100];
    line.backgroundColor=tableView.separatorColor;

    cell.backgroundColor=self.leftUnSelectBgColor;
}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    DLog();
    rightMeun * title=self.allData[self.selectIndex];
    if (title.nextArray.count==0) {
        return 0;
    }
    //一级菜单对象
     return   1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    rightMeun * title=self.allData[self.selectIndex];
    return title.nextArray.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    rightMeun * title=self.allData[self.selectIndex];
    NSArray * list;
    
    rightMeun * meun;
    
    meun=title.nextArray[indexPath.section];
    
    if (meun.nextArray.count>0) {
        meun=title.nextArray[indexPath.section];
        list=meun.nextArray;
        meun=list[indexPath.row];
    }


    void (^select)(NSInteger left,NSInteger right,id info) = self.block;
    
    select(self.selectIndex,indexPath.row,meun);
    
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MultilevelCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kMultilevelCollectionViewCell forIndexPath:indexPath];
    rightMeun * title=self.allData[self.selectIndex];
    NSArray * list;
    
    rightMeun * meun;

    meun=title.nextArray[indexPath.section];

    if (meun.nextArray.count>0) {
        meun=title.nextArray[indexPath.section];
        list=meun.nextArray;
        meun=list[indexPath.row];
    }
    
    cell.titile.text=meun.meunName;
    cell.backgroundColor=[UIColor clearColor];
    cell.imageView.backgroundColor=UIColorFromRGB(0xF8FCF8);
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:meun.urlName] placeholderImage:[UIImage imageNamed:kImageDefaultName]];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier;
    if ([kind isEqualToString: UICollectionElementKindSectionFooter ]){
        reuseIdentifier = @"footer";
    }else{
        reuseIdentifier = kMultilevelCollectionHeader;
    }
    
    rightMeun * title=self.allData[self.selectIndex];
    
    CollectionHeader *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
        if (title.nextArray.count>0) {
            rightMeun * meun;
            meun=title.nextArray[indexPath.section];
            NSString* banner = title.bannerAd.img;
            if ([banner containsString:@".gif"])
            {
                view.bannerAdImageview = [AnimatedGif getAnimationForGifAtUrl:[NSURL URLWithString:banner]];
                
            }
            else if ([banner containsString:@".png"])
            {
                [view.bannerAdImageview sd_setImageWithURL:[NSURL URLWithString:banner] placeholderImage:[UIImage imageNamed:kImageDefaultName]];
            }
        }
        else{
            return nil;
        }
    }
    return view;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(88, 120);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={kScreenWidth,80};
    return size;
}


#pragma mark---记录滑动的坐标
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.rightCollection]) {
        self.isReturnLastOffset=YES;
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([scrollView isEqual:self.rightCollection]) {
        
        rightMeun * title=self.allData[self.selectIndex];
        
        title.offsetScorller=scrollView.contentOffset.y;
        self.isReturnLastOffset=NO;
        
    }

 }

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.rightCollection]) {
        
        rightMeun * title=self.allData[self.selectIndex];
        
        title.offsetScorller=scrollView.contentOffset.y;
        self.isReturnLastOffset=NO;
    }

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.rightCollection] && self.isReturnLastOffset) {
        rightMeun * title=self.allData[self.selectIndex];
        title.offsetScorller=scrollView.contentOffset.y;
    }
}



#pragma mark--Tools
-(void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

@end


@implementation BannerAdForm
- (instancetype)init
{
    if (self = [super init]) {
        return self;
    }
    return nil;
}
@end


@implementation rightMeun

- (instancetype)init{
    if (self  = [super init]) {
        self.nextArray = [NSMutableArray array];
        self.bannerAd = [[BannerAdForm alloc]init];
        return self;
    }
    return nil;
}
@end
