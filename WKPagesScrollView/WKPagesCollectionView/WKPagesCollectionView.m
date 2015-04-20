//
//  WKPagesScrollView.m
//  WKPagesScrollView
//
//  Created by 秦 道平 on 13-11-14.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "WKPagesCollectionView.h"

@interface WKPagesCollectionView () 

@property (nonatomic, strong) UIImageView *maskImageView;

@end

@implementation WKPagesCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    WKPagesCollectionViewFlowLayout *flowLayout = [[WKPagesCollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = frame.size;
    
    return [self initWithFrame:frame collectionViewLayout:flowLayout];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.highLightAnimationDuration = 0.3;
        self.dismisalAnimationDuration = 0.3;
    }
    
    return self;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];

    if (hidden){
        if (_maskImageView) {
            [_maskImageView removeFromSuperview];
            _maskImageView = nil;
        }
    }
    else {
        [self setMaskShow:self.maskShow];
    }
}

- (void)setMaskShow:(BOOL)maskShow
{
    _maskShow = maskShow;
    
    if (maskShow){
        if (!_maskImageView){
            _maskImageView = [[UIImageView alloc]initWithImage:[self makeGradientImage]];
            [self.superview addSubview:_maskImageView];
        }
        _maskImageView.hidden = NO;
        
    } else {
        _maskImageView.hidden = YES;
    }
}

- (UIImage *)makeGradientImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 1.0f);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 3;
    CGFloat locations[] = { 0.0,0.6f, 1.0};
    CGFloat components[] = {
        0.0,0.0,0.0,0.0,  // Start color
        0.0,0.0,0.0,0.2,
        0.0,0.0,0.0,0.6}; // End color
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
    CGPoint myStartPoint={self.bounds.size.width/2,self.bounds.size.height/2};
    CGFloat myStartRadius=0, myEndRadius=self.bounds.size.width;
    CGContextDrawRadialGradient (context, myGradient, myStartPoint,
                                 myStartRadius, myStartPoint, myEndRadius,
                                 kCGGradientDrawsAfterEndLocation);
    
    UIImage* image=UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(context);
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Actions

- (void)showCellToHighLightAtIndexPath:(NSIndexPath *)indexPath completion:(void (^)(BOOL))completion
{
    NSLog(@"row:%ld",(long)indexPath.row);
    
    if (indexPath.row >= [self numberOfItemsInSection:indexPath.section]){
        return;
    }
    
    if (_isHighLight){
        return;
    }

    BOOL noScroll = NO;
    NSArray* visibleIndexPaths = [self indexPathsForVisibleItems];
    for (NSIndexPath *visibleIndexPath in visibleIndexPaths) {
        if (indexPath.row == visibleIndexPath.row){
            noScroll = YES;
        }
    }
    if (!noScroll){
        [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    }
    
    double delayInSeconds = 0.3f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.maskShow = YES;
        _maskImageView.hidden = NO;
        _maskImageView.alpha = 1.0;
        self.scrollEnabled = NO;
        [UIView animateWithDuration:self.highLightAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.visibleCells enumerateObjectsUsingBlock:^(WKPagesCollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
                NSIndexPath* visibleIndexPath = [self indexPathForCell:cell];
                if (visibleIndexPath.row == indexPath.row){
                    cell.state = WKPagesCollectionViewCellStateHightlight;
                    
                } else if (visibleIndexPath.row < indexPath.row) {
                    cell.state = WKPagesCollectionViewCellStateBackToTop;
                    
                } else if (visibleIndexPath.row > indexPath.row) {
                    NSLog(@"indexPath:%ld,visibleIndexPath:%ld",(long)indexPath.row,(long)visibleIndexPath.row);
                    cell.state = WKPagesCollectionViewCellStateBackToBottom;
                    
                } else {
                    cell.state = WKPagesCollectionViewCellStateNormal;
                }
                _maskImageView.alpha = 0.0;
            }];
            
        } completion:^(BOOL finished) {
            _isHighLight = YES;
            self.maskShow = NO;
            if (completion) {
                completion(finished);
            }

            if ([self.delegate respondsToSelector:@selector(collectionView:didShownToHightlightAtIndexPath:)]){
                [(id<WKPagesCollectionViewDelegate>)self.delegate collectionView:self didShownToHightlightAtIndexPath:indexPath];
            }
        }];
    });
}

- (void)showCellToHighLightAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self numberOfItemsInSection:indexPath.section]) {
        return;
    }

    if (_isHighLight){
        return;
    }

    double delayInSeconds = 0.01f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.maskShow = NO;
        self.scrollEnabled = NO;
        [self.visibleCells enumerateObjectsUsingBlock:^(WKPagesCollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
            NSIndexPath* visibleIndexPath = [self indexPathForCell:cell];
            if (visibleIndexPath.row == indexPath.row){
                cell.state = WKPagesCollectionViewCellStateHightlight;
            }
            else if (visibleIndexPath.row<indexPath.row){
                cell.state = WKPagesCollectionViewCellStateBackToTop;
            }
            else if (visibleIndexPath.row>indexPath.row){
                cell.state = WKPagesCollectionViewCellStateBackToBottom;
            }
            else{
                cell.state = WKPagesCollectionViewCellStateNormal;
            }
        }];
        _isHighLight=YES;
    });
    
}

- (void)dismissFromHightLightWithCompletion:(void (^)(BOOL))completion
{
    self.maskShow = YES;
    _maskImageView.alpha = 0.0;

    if (!_isHighLight)
        return;
    
    [UIView animateWithDuration:self.dismisalAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.visibleCells enumerateObjectsUsingBlock:^(WKPagesCollectionViewCell *cell, NSUInteger idx, BOOL *stop) {
            cell.state = WKPagesCollectionViewCellStateNormal;
            _maskImageView.alpha = 1.0;
        }];
        
    } completion:^(BOOL finished) {
        self.scrollEnabled = YES;
        _isHighLight = NO;
        
        if (completion != nil) {
            completion(finished);
        }
        
        if ([self.delegate respondsToSelector:@selector(didDismissFromHightlightOnCollectionView:)]){
            [(id<WKPagesCollectionViewDelegate>)self.delegate didDismissFromHightlightOnCollectionView:self];
        }
    }];
}

- (void)appendItem
{
    if (self.isAddingNewPage) {
        return;
    }
    
    self.isAddingNewPage = YES;
    if (self.isHighLight){
        [self dismissFromHightLightWithCompletion:^(BOOL finished) {
            [self addNewPage];
        }];
    }
    else{
        [self addNewPage];
    }
}

- (void)addNewPage
{
    NSInteger total = [self numberOfItemsInSection:0];
    if (total > 0) {
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:total-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
    
    double delayInSeconds = 0.001f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        ///Add Data
        if ([self.dataSource respondsToSelector:@selector(willAppendItemInCollectionView:)]) {
            [(id<WKPagesCollectionViewDataSource>)self.dataSource willAppendItemInCollectionView:self];
        }

        NSInteger lastRow = total;
        NSIndexPath *insertIndexPath=[NSIndexPath indexPathForItem:lastRow inSection:0];
        [self performBatchUpdates:^{
            [self insertItemsAtIndexPaths:@[insertIndexPath]];
        } completion:^(BOOL finished) {
            double delayInSeconds = 0.001f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self showCellToHighLightAtIndexPath:insertIndexPath completion:^(BOOL finished) {
                    self.isAddingNewPage = NO;
                }];
            });
            
        }];
    });
}

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *view = [super hitTest:point withEvent:event];
    if (!view){
        return nil;
    }
    if (view == self){
        for (WKPagesCollectionViewCell *cell in self.visibleCells) {
            if (cell.state == WKPagesCollectionViewCellStateHightlight){
                return cell.cellContentView;///Events should only be passed to this layer
            }
        }
    }
    return view;
}

#pragma mark - WKPagesCollectionViewCellDelegate

- (CGPoint)contentOffsetForPagesCollectionViewCell:(WKPagesCollectionViewCell *)cell
{
    return self.contentOffset;
}

- (NSIndexPath *)indexPathForPagesCollectionViewCell:(WKPagesCollectionViewCell *)cell
{
    return [self indexPathForCell:cell];
}

- (CGFloat)pageHeightForPagesCollectionViewCell:(WKPagesCollectionViewCell *)cell
{
    WKPagesCollectionViewFlowLayout *collectionLayout = (WKPagesCollectionViewFlowLayout*)self.collectionViewLayout;
    return collectionLayout.pageHeight;
}

- (void)pagesCollectionViewCellTapped:(WKPagesCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    [self showCellToHighLightAtIndexPath:indexPath completion:^(BOOL finished) {
        NSLog(@"highlight completed");
    }];
}

- (void)pagesCollectionViewCellTappedClose:(WKPagesCollectionViewCell *)cell
{
    NSIndexPath* indexPath = [self indexPathForCell:cell];
    NSLog(@"delete cell at %ld",(long)indexPath.row);
    //Delete data
    id<WKPagesCollectionViewDataSource> pagesDataSource = (id<WKPagesCollectionViewDataSource>)self.dataSource;
    if ([pagesDataSource respondsToSelector:@selector(collectionView:willRemoveCellAtIndexPath:)]) {
        [pagesDataSource collectionView:self willRemoveCellAtIndexPath:indexPath];
    }

    //Animation
    [self performBatchUpdates:^{
        [self deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        if ([pagesDataSource respondsToSelector:@selector(collectionView:didRemoveCellAtIndexPath:)]) {
            [pagesDataSource collectionView:self didRemoveCellAtIndexPath:indexPath];
        }
    }];
}

@end
