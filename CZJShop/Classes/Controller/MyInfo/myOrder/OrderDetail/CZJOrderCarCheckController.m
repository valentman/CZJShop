//
//  CZJOrderCarCheckController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderCarCheckController.h"
#import "CZJBaseDataManager.h"
#import "CZJOrderForm.h"
#import "CZJCommentCell.h"
#import "CZJOrderCarCheckCell.h"
#import "CZJOrderBuildingImagesCell.h"
#import "CZJOrderBuildCarCell.h"

@interface CZJOrderCarCheckController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    CZJCarCheckForm* carCheckForm;
}

@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJOrderCarCheckController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getCarCheckInfoFromServer];
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"车况检查";
    
    
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJCommentCell",
                         @"CZJOrderCarCheckCell",
                         @"CZJOrderBuildingImagesCell",
                         @"CZJOrderBuildCarCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
    
}

- (void)getCarCheckInfoFromServer
{
    NSDictionary* params = @{@"orderNo":self.orderNo};
    [CZJBaseDataInstance getOrderCarCheck:params Success:^(id json) {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        carCheckForm  = [CZJCarCheckForm objectWithKeyValues:dict];

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
    return 2 + carCheckForm.checks.count + carCheckForm.photos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1;
    }
    else if (1 == section ||
             2 == section)
    {
        return 2;
    }
    else
    {
        return ((CZJCarCheckItemsForm*)carCheckForm.checks[section - 3]).items.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        CZJOrderBuildCarCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderBuildCarCell" forIndexPath:indexPath];
        [cell.carBrandImg sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:IMAGENAMED(@"default_icon_car")];
        cell.myCarInfoLabel.text = [NSString stringWithFormat:@"%@ %@ %@",carCheckForm.car.brandName, carCheckForm.car.seriesName, carCheckForm.car.numberPlate];
        cell.myCarModelLabel.text = carCheckForm.car.modelName;
        return cell;
    }
    
    else if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJOrderBuildingImagesCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderBuildingImagesCell" forIndexPath:indexPath];
            cell.myTitleLabel.text = @"车况拍照";
            return cell;
        }
        else
        {
            UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            NSArray* photosAry = carCheckForm.photos;
            for (int i = 0; i< photosAry.count; i++)
            {
                UIImageView* image = [[UIImageView alloc]init];
                image.frame = [CZJUtils viewFramFromDynamic:CZJMarginMake(15, 10) size:CGSizeMake(78, 78) index:i divide:4];
                [cell addSubview:image];
                [image sd_setImageWithURL:[NSURL URLWithString:photosAry[i]] placeholderImage:IMAGENAMED(@"")];
            }
            if (photosAry.count == 0)
            {
                UILabel* textlabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 100, 15)];
                [cell addSubview:textlabel];
                
                textlabel.text = @"暂未拍照";
                textlabel.textColor = [UIColor lightGrayColor];
                textlabel.font = SYSTEMFONT(12);
            }
            return cell;
        }
    }
    else if (2 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJOrderBuildingImagesCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderBuildingImagesCell" forIndexPath:indexPath];
            cell.myTitleLabel.text = @"车况备注";
            return cell;
        }
        else
        {
            CZJCommentCell* cell  = [tableView dequeueReusableCellWithIdentifier:@"CZJCommentCell" forIndexPath:indexPath];
            cell.commentLabel.text = carCheckForm.checkNote;
            CGSize comentSize = [CZJUtils calculateStringSizeWithString:carCheckForm.checkNote Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 50];
            cell.commentHeight.constant =comentSize.height;
            return cell;
        }
    }
    else
    {
        CZJCarCheckItemsForm* checkTypeForm =  (CZJCarCheckItemsForm*)carCheckForm.checks[indexPath.section - 3];
        if (0 == indexPath.row)
        {
            CZJOrderBuildingImagesCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderBuildingImagesCell" forIndexPath:indexPath];
            cell.myTitleLabel.text = checkTypeForm.checkType;
            return cell;
        }
        else
        {
            CZJCarCheckItemForm* checkItemForm = (CZJCarCheckItemForm*)checkTypeForm.items[indexPath.row - 1];
            CZJOrderCarCheckCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderCarCheckCell" forIndexPath:indexPath];
            cell.itemNameLabel.text = checkItemForm.checkItem;
            if ([checkItemForm.checkResult isEqualToString:@"正常"])
            {
                cell.checkBtn.selected = YES;
                cell.noteLabel.hidden = YES;
            }
            else
            {
                cell.noteLabel.hidden = NO;
                cell.noteLabel.text = checkItemForm.note;
                cell.checkBtn.selected = NO;
            }
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
    else if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 46;
        }
        else
        {
            if (carCheckForm.photos.count > 0)
            {
                return (78 + 10)* (carCheckForm.photos.count > 4 ? 2 : 1) ;
            }
            else
            {
                return 46;
            }
            
        }
    }
    else if (2 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 46;
        }
        else
        {
            CGSize noteSize = [CZJUtils calculateStringSizeWithString:carCheckForm.checkNote Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 2* 15 - 10 * 2];
            if (noteSize.height < 80)
            {
                return 100;
            }
            else
            {
                return noteSize.height + 20;
            }
        }
    }
    else
    {
        if (0 == indexPath.row)
        {
            return 46;
        }
        else
        {
            CZJCarCheckItemsForm* checkItemsForm =  (CZJCarCheckItemsForm*)carCheckForm.checks[indexPath.section - 3];
            CZJCarCheckItemForm* checkItemForm = (CZJCarCheckItemForm*)checkItemsForm.items[indexPath.row - 1];
            if ([checkItemForm.checkResult isEqualToString:@"正常"])
            {
                return 46;
            }
            else
            {
                NSString* checkNote = checkItemForm.note;
                CGSize noteSize = [CZJUtils calculateStringSizeWithString:checkNote Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH];
                if (noteSize.height < 15)
                {
                    return 100;
                }
                else
                {
                    return noteSize.height + 100 - 15;
                }
            }
        }
    }

    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
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

@end
