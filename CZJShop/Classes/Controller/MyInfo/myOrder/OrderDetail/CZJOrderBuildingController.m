//
//  CZJOrderBuildingController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderBuildingController.h"
#import "CZJOrderBuilderCell.h"
#import "CZJOrderBuildCarCell.h"
#import "CZJOrderBuildingImagesCell.h"
#import "CZJBaseDataManager.h"

@interface CZJOrderBuildingController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    CZJOrderDetailBuildForm* builderData;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation CZJOrderBuildingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getBuildingInfoFromServer];
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"正在施工";
    
    NSArray* nibArys = @[@"CZJOrderBuilderCell",
                         @"CZJOrderBuildCarCell",
                         @"CZJOrderBuildingImagesCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)getBuildingInfoFromServer
{
    NSDictionary* params = @{@"orderNo":self.orderNo};
    [CZJBaseDataInstance getOrderBuildProgress:params Success:^(id json) {
        builderData = [CZJOrderDetailBuildForm objectWithKeyValues:[[CZJUtils DataFromJson:json] valueForKey:@"msg"]];
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        [self.myTableView reloadData];
    } fail:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (2 == section)
    {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        CZJOrderBuildCarCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderBuildCarCell" forIndexPath:indexPath];
        [cell.carBrandImg sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:DefaultPlaceHolderSquare];
        NSString* carBrandName = builderData.car.brandName;
        NSString* carSeriesName = builderData.car.seriesName;
        NSString* carNumberPlate = builderData.car.numberPlate;
        cell.myCarInfoLabel.text = [NSString stringWithFormat:@"%@ %@ %@",carBrandName, carSeriesName, carNumberPlate];
        cell.myCarModelLabel.text = builderData.car.modelName;
        return cell;
    }
    if (1 == indexPath.section)
    {
        CZJOrderBuilderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderBuilderCell" forIndexPath:indexPath];
        cell.builderNameLabel.text = builderData.builder;
        cell.buildingLabel.hidden = YES;
        
        [cell.builderHeadImg sd_setImageWithURL:[NSURL URLWithString:builderData.head] placeholderImage:IMAGENAMED(@"order_head_default.png")];
        CGSize size = [CZJUtils calculateTitleSizeWithString:builderData.useTime AndFontSize:12];
        cell.leftTimeLabelWidth.constant = size.width + 40;
        cell.leftTimeLabel.text = [NSString stringWithFormat:@"已用时%@",builderData.useTime];
        cell.separatorInset = HiddenCellSeparator;
        return cell;
    }
    if (2 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJOrderBuildingImagesCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderBuildingImagesCell" forIndexPath:indexPath];
            cell.myTitleLabel.text = @"施工图片";
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
        else
        {
            UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            NSArray* photosAry = builderData.photos;
            for (int i = 0; i< photosAry.count; i++)
            {
                CZJImageView* image = [[CZJImageView alloc]initWithFrame:[CZJUtils viewFramFromDynamic:CZJMarginMake(15, 10) size:CGSizeMake(78, 78) index:i divide:4]];
                image.subTag = i;
                [image addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigImage:)]];
                [cell addSubview:image];
                [image sd_setImageWithURL:[NSURL URLWithString:photosAry[i]] placeholderImage:DefaultPlaceHolderSquare];
            }
            if (photosAry.count == 0)
            {
                UILabel* textlabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 100, 15)];
                [cell addSubview:textlabel];
                
                textlabel.text = @"暂未拍照";
                textlabel.textColor = [UIColor lightGrayColor];
                textlabel.font = SYSTEMFONT(12);
            }
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
        
    }
    return nil;
}
    
    


#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        return 82;
    }
    if (1 == indexPath.section)
    {
        return 167;
    }
    if (2 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 44;
        }
        if (1 == indexPath.row)
        {
            if (builderData.photos.count > 0)
            {
                return 100;
            }
            //动态调整的
            return 44;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (1 == section)
    {
        return 10;
    }
    return 0;
}

//去掉tableview中section的headerview粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


#pragma mark- 点小图显示大图
- (void)showBigImage:(UIGestureRecognizer*)recogonizer
{
    CZJImageView* evalutionImg = (CZJImageView*)recogonizer.view;
    //通过view的tag值可以获取section值，取到相应的数据

    [CZJUtils showDetailInfoWithIndex:evalutionImg.subTag withImgAry:builderData.photos onTarget:self];

}
@end
