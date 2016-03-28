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
#import "CZJBaseDataManager.h"
#import "AnimatedGif.h"
#import "CollectionHeader.h"

#define kImageDefaultName @"tempShop"
#define kMultilevelCollectionViewCell @"MultilevelCollectionViewCell"
#define kMultilevelCollectionHeader   @"CollectionHeader"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width


@interface MultilevelMenu()
{
    NSString* currentTypeID;
}
@property(strong,nonatomic ) UITableView * leftTablew;
@property(strong,nonatomic ) UICollectionView * rightCollection;
@property(assign,nonatomic) BOOL isReturnLastOffset;

@end
@implementation MultilevelMenu


-(id)initWithFrame:(CGRect)frame WithData:(NSArray *)data withSelectIndex:(SelectBlock)selectIndex
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
        self.rightCollection.backgroundColor = [UIColor blueColor];
        self.rightCollection.clipsToBounds =NO;
        
        //注册可用视图
        UINib *nib=[UINib nibWithNibName:kMultilevelCollectionViewCell bundle:nil];
        [self.rightCollection registerNib: nib forCellWithReuseIdentifier:kMultilevelCollectionViewCell];
        
        UINib *header=[UINib nibWithNibName:kMultilevelCollectionHeader bundle:nil];
        [self.rightCollection registerNib:header forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMultilevelCollectionHeader];
        
        [self addSubview:self.rightCollection];
        
        //默认点击第一个
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

- (void)getCategoryDataFromServer
{
    __weak typeof(self) weak = self;
    [MBProgressHUD showHUDAddedTo:self.rightCollection animated:YES];
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
        tempMenu.bannerAd = [BannerAdForm objectWithKeyValues:banners];
        [self.rightCollection reloadData];
    };
    
    CZJFailureBlock failBlock = ^{
        [MBProgressHUD hideAllHUDsForView:self animated:YES];
        [CZJUtils showReloadAlertViewOnTarget:self.rightCollection withReloadHandle:^{
            [weak getCategoryDataFromServer];
        }];
    };
    
    [CZJBaseDataInstance showCategoryTypeId:currentTypeID success:successBlock fail:failBlock];
}

#pragma mark-----------------------左边的tablewView 代理-------------------------
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
        
        UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
        label.backgroundColor=tableView.separatorColor;
        label.textAlignment = NSTextAlignmentCenter;
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
    currentTypeID = title.ID;
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
        [self getCategoryDataFromServer];
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



#pragma mark---------------------imageCollectionView--------------------------
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
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
    rightMeun * touchedItemMeun=title.nextArray[indexPath.item];
    if (self.block)
    {
        self.block(self.selectIndex,indexPath.item,touchedItemMeun);
    }
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MultilevelCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kMultilevelCollectionViewCell forIndexPath:indexPath];
    rightMeun * title=self.allData[self.selectIndex];
    rightMeun * itemMenu=title.nextArray[indexPath.item];

    cell.titile.text=itemMenu.meunName;
    cell.imageView.backgroundColor=UIColorFromRGB(0xF8FCF8);
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:itemMenu.urlName] placeholderImage:[UIImage imageNamed:kImageDefaultName]];
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
    [view.bannerBtn addTarget:self action:@selector(bannerADClick:) forControlEvents:UIControlEventTouchUpInside];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
        if (title.nextArray.count>0) {
            rightMeun * meun;
            meun=title.nextArray[indexPath.section];
            NSString* banner = title.bannerAd.img;
            
            if (!banner)
            {
                return nil;
            }
            if ([banner containsString:@".gif"])
            {
                view.bannerAdImageview = [AnimatedGif getAnimationForGifAtUrl:[NSURL URLWithString:banner]];
            }
            else
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
    int width = (PJ_SCREEN_WIDTH - ((iPhone5 || iPhone4) ? 128 : 140))/3;
    int height = (width * 120)/88;
    return CGSizeMake(width, height);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    float ratio = 160.0 / 526.0;
    NSInteger height = (kScreenWidth - 120)*ratio;
    rightMeun * title=self.allData[self.selectIndex];
    if (title.nextArray.count>0)
    {
        rightMeun * meun;
        meun=title.nextArray[section];
        NSString* banner = title.bannerAd.img;
        if (!banner)
        {
            height = 0;
        }
    }
    
    CGSize size={kScreenWidth, height};
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

-(void)bannerADClick:(id)sender
{
    rightMeun * title=self.allData[self.selectIndex];
    if (title.nextArray.count>0)
    {
        rightMeun * meun;
        meun=title.nextArray[0];
        NSString* url = title.bannerAd.value;
        if (url)
        {
            self.block(self.selectIndex, -1, url);
        }
    }
    
}


@end


@implementation BannerAdForm
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
