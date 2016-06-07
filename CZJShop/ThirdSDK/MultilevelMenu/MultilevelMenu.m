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
        self.leftTitleSelectColor = RGB(240, 50, 50);
        self.leftTitleUnSelectColor = BLACKCOLOR;
        
        self.leftSelectBgColor = CZJNAVIBARBGCOLOR;
        self.leftBgColor = WHITECOLOR;
        self.leftUnSelectBgColor = WHITECOLOR;
        
        self.leftSeparatorColor = UIColorFromRGB(0xE5E5E5);
        
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
        flowLayout.minimumLineSpacing=10.f;
        float leftMargin =0;
        self.rightCollection=[[UICollectionView alloc] initWithFrame:CGRectMake(kLeftWidth+leftMargin,0,kScreenWidth-kLeftWidth-leftMargin*2,frame.size.height) collectionViewLayout:flowLayout];
        
        self.rightCollection.delegate=self;
        self.rightCollection.dataSource=self;
        self.rightCollection.clipsToBounds =NO;
        
        //注册可用视图
        UINib *nib=[UINib nibWithNibName:kMultilevelCollectionViewCell bundle:nil];
        [self.rightCollection registerNib: nib forCellWithReuseIdentifier:kMultilevelCollectionViewCell];
        
        UINib *header=[UINib nibWithNibName:kMultilevelCollectionHeader bundle:nil];
        [self.rightCollection registerNib:header forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMultilevelCollectionHeader];
        
        [self addSubview:self.rightCollection];
        
        //默认点击第一个
        self.selelctIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        if (_allData.count>0) {
            [self tableView:self.leftTablew didSelectRowAtIndexPath: self.selelctIndexPath];
        }
        [self registNotification];
      
        self.isReturnLastOffset=YES;
        self.rightCollection.backgroundColor=self.leftSelectBgColor;
        self.backgroundColor=self.leftSelectBgColor;
        
    }
    return self;
}

- (void)registNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clickService) name:@"moreService" object:nil];
}

- (void)clickService
{
    NSIndexPath* defaultPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath* lastPath = [NSIndexPath indexPathForRow:_selectIndex inSection:0];
    [self tableView:self.leftTablew didDeselectRowAtIndexPath:lastPath];
    [self tableView:self.leftTablew didSelectRowAtIndexPath: defaultPath];
}


//---------颜色配置--------
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

    [CZJUtils removeReloadAlertViewFromTarget:self.rightCollection];
    [CZJUtils removeNoDataAlertViewFromTarget:self.rightCollection];
    //从服务器获取数据成功返回回调
    CZJSuccessBlock successBlock = ^(id json){
        NSDictionary* tempdata = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        DLog(@"%@",[tempdata description]);
        //分类数据信息
        /**
         *  这个通过比较返回数据的父id与当前点击分类的id是否相同来将数据放入相应的分类子项目数组里
         *  如果不做此判断，则会出现数据混入的情况，比如明明请求的是线下服务的数据会因为网络延迟
         *  在点击请求油品化学品分类数据后，显示在油品化学品分类里面。
         */
        NSArray* types = [rightMeun objectArrayWithKeyValuesArray:[tempdata valueForKey:@"types"]];
        rightMeun* tempRightMenu = types.firstObject;
        rightMeun* tempLeftMenu;
        for (int i = 0; i < _allData.count; i++)
        {
            tempLeftMenu = _allData[i];
            if ([tempLeftMenu.typeId isEqualToString:tempRightMenu.parentId])
            {
                //分类子项目
                [tempLeftMenu.nextArray addObjectsFromArray:types];
                
                //广告栏信息
                NSDictionary* banners = [[tempdata valueForKey:@"msg"] valueForKey:@"banner"];
                tempLeftMenu.bannerAd = [BannerAdForm objectWithKeyValues:banners];
                self.rightCollection.hidden = NO;
                [self.rightCollection reloadData];
                break;
            }
        }
    };
    
    CZJFailureBlock failBlock = ^{
        [CZJUtils showReloadAlertViewOnTarget:self.rightCollection withReloadHandle:^{
            weak.rightCollection.hidden = YES;
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
    return _allData.count;
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
    rightMeun * title = _allData[indexPath.row];
    cell.titile.text=title.meunName;
    
    UILabel * line=(UILabel*)[cell viewWithTag:100];
    
    if (indexPath.row==self.selectIndex) {
        cell.titile.textColor=self.leftTitleSelectColor;
        cell.backgroundColor=self.leftSelectBgColor;
        line.backgroundColor=cell.backgroundColor;
    }
    else{
        cell.titile.textColor=self.leftTitleUnSelectColor;
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
    cell.titile.textColor=self.leftTitleSelectColor;
    cell.backgroundColor=self.leftSelectBgColor;
    self.selectIndex = indexPath.row;
    cell.selected = YES;
    rightMeun * title = _allData[indexPath.row];
    currentTypeID = title.typeId;
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
    
    self.rightCollection.hidden = YES;
    if (nextAry.count <= 0) {
        [self getCategoryDataFromServer];
    }
    else
    {
        self.rightCollection.hidden = NO;
        [self.rightCollection reloadData];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MultilevelTableViewCell * cell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.titile.textColor=self.leftTitleUnSelectColor;
    UILabel * line=(UILabel*)[cell viewWithTag:100];
    line.backgroundColor=tableView.separatorColor;
    cell.backgroundColor=self.leftUnSelectBgColor;
}



#pragma mark---------------------imageCollectionView--------------------------
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    rightMeun * title = _allData[self.selectIndex];
    if (title.nextArray.count==0) {
        return 0;
    }
    //一级菜单对象
     return   1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    rightMeun * title = _allData[self.selectIndex];
    return title.nextArray.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    rightMeun * title = _allData[self.selectIndex];
    if (title.nextArray.count <= 0)
    {
        return;
    }
    rightMeun * touchedItemMeun=title.nextArray[indexPath.item];
    if (self.block)
    {
        self.block(self.selectIndex,indexPath.item,touchedItemMeun);
    }
}

//返回CollectionCell
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MultilevelCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kMultilevelCollectionViewCell forIndexPath:indexPath];
    rightMeun * title = _allData[self.selectIndex];
    rightMeun * itemMenu=title.nextArray[indexPath.item];

    cell.titile.text=itemMenu.meunName;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:itemMenu.urlName] placeholderImage:DefaultPlaceHolderSquare];
    return cell;
}


//返回CollectionView广告Cell
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier;
    if ([kind isEqualToString: UICollectionElementKindSectionFooter ]){
        reuseIdentifier = @"footer";
    }else{
        reuseIdentifier = kMultilevelCollectionHeader;
    }
    
    rightMeun * title = _allData[self.selectIndex];
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
                [view.bannerAdImageview sd_setImageWithURL:[NSURL URLWithString:banner] placeholderImage:DefaultPlaceHolderRectangle];
            }
        }
        else{
            return nil;
        }
    }
    return view;
}

//返回collectionCell尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    int width = (iPhone4 || iPhone5) ? 65 : (PJ_SCREEN_WIDTH - 140)/3;
    int height = width + 25;
    return CGSizeMake(width, height);
}


//返回Header广告栏长宽尺寸
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    float ratio = 160.0 / 526.0;
    NSInteger height = (kScreenWidth - 120)*ratio;
    rightMeun * title= _allData[self.selectIndex];
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


//返回
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 10, 10);
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
        rightMeun * title = _allData[self.selectIndex];
        title.offsetScorller=scrollView.contentOffset.y;
        self.isReturnLastOffset=NO;
    }
 }

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.rightCollection]) {
        
        rightMeun * title = _allData[self.selectIndex];
        
        title.offsetScorller=scrollView.contentOffset.y;
        self.isReturnLastOffset=NO;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.rightCollection] && self.isReturnLastOffset) {
        rightMeun * title= _allData[self.selectIndex];
        title.offsetScorller=scrollView.contentOffset.y;
    }
}

-(void)bannerADClick:(id)sender
{
    rightMeun * title= _allData[self.selectIndex];
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

+(NSDictionary*)replacedKeyFromPropertyName
{
    return @{@"urlName" : @"img",
             @"meunName" : @"name"};
}
@end
