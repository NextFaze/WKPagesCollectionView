//
//  WKPagesCollectionViewCell.h
//  WKPagesScrollView
//
//  Created by 秦 道平 on 13-11-15.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKCloseButton.h"

typedef NS_ENUM(NSUInteger, WKPagesCollectionViewCellState) {
    WKPagesCollectionViewCellStateNormal,
    WKPagesCollectionViewCellStateHightlight,
    WKPagesCollectionViewCellStateBackToTop,
    WKPagesCollectionViewCellStateBackToBottom,
};

@class WKPagesCollectionViewCell;

@protocol WKPagesCollectionViewCellDelegate <NSObject>

#warning the following three methods should be removed - the cell should not need to know so much about its layout
- (CGPoint)contentOffsetForPagesCollectionViewCell:(WKPagesCollectionViewCell *)cell;
- (NSIndexPath *)indexPathForPagesCollectionViewCell:(WKPagesCollectionViewCell *)cell;
- (CGFloat)pageHeightForPagesCollectionViewCell:(WKPagesCollectionViewCell *)cell;

- (void)pagesCollectionViewCellTapped:(WKPagesCollectionViewCell *)cell;
- (void)pagesCollectionViewCellTappedClose:(WKPagesCollectionViewCell *)cell;

@end

@interface WKPagesCollectionViewCell : UICollectionViewCell <UIScrollViewDelegate>

@property (nonatomic, assign) NSObject<WKPagesCollectionViewCellDelegate> *delegate;
@property (nonatomic, strong) WKCloseButton *closeButton;
@property (nonatomic, assign) CATransform3D normalTransform;
@property (nonatomic, assign) CGRect normalFrame;
@property (nonatomic, assign) WKPagesCollectionViewCellState state;
@property (nonatomic, strong) UIView *cellContentView;

@end
