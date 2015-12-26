//
//  CZJDetailPicShowCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePlayerView.h"

@interface CZJDetailPicShowCell : CZJTableViewCell<ImagePlayerViewDelegate>
{
     NSMutableArray* _imageArray;
}

@property (weak, nonatomic) IBOutlet ImagePlayerView *picDetailView;
@property (weak, nonatomic) NSMutableArray* activeties;
@property (weak, nonatomic) id<CZJImageViewTouchDelegate> delegate;

- (void)someMethodNeedUse:(NSIndexPath *)indexPath DataModel:(NSMutableArray*)array;
@end
