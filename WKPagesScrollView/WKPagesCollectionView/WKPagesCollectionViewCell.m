//
//  WKPagesCollectionViewCell.m
//  WKPagesScrollView
//
//  Created by 秦 道平 on 13-11-15.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "WKPagesCollectionViewCell.h"
#import "WKPagesCollectionView.h"
#import "WKCloseButton.h"

@interface WKPagesCollectionViewCell ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation WKPagesCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.tag = 100;
        
        CGRect rect=CGRectMake(0.0f, 0.0f,
                               [UIScreen mainScreen].bounds.size.width,
                               [UIScreen mainScreen].bounds.size.height);

        self.scrollView = [[UIScrollView alloc] initWithFrame:rect];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.scrollView.clipsToBounds = NO;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = YES;
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width + 1.0, self.scrollView.frame.size.height);
        self.scrollView.delegate=self;
        [self.contentView addSubview:_scrollView];
        self.scrollView.tag = 101;
        
        self.cellContentView = [[UIView alloc] initWithFrame:rect];
        self.cellContentView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.scrollView addSubview:self.cellContentView];
        self.cellContentView.tag=102;

        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
        [self.scrollView addGestureRecognizer:self.tapGestureRecognizer];
        
        self.closeButton = [[WKCloseButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
        [self.closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:self.closeButton];
    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    for (UIView *view in self.cellContentView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)tapGestureRecognized:(UITapGestureRecognizer*)tapGesture
{
    if ([self.delegate respondsToSelector:@selector(pagesCollectionViewCellTapped:)]) {
        [self.delegate pagesCollectionViewCellTapped:self];
    }
}

- (void)closeButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(pagesCollectionViewCellTappedClose:)]) {
        [self.delegate pagesCollectionViewCellTappedClose:self];
    }
}

#pragma mark -

#warning this method should be reviewed - the transform/layout code can be handled by the collection view layout instead of the cell itself
- (void)setState:(WKPagesCollectionViewCellState)state
{
    if (_state == state)
        return;
    
    _state = state;
    
    CGFloat pageHeight = [self.delegate pageHeightForPagesCollectionViewCell:self];
    
    switch (state) {
        case WKPagesCollectionViewCellStateHightlight: {
            self.normalTransform = self.layer.transform;
            _scrollView.scrollEnabled = NO;
            _closeButton.hidden = YES;
            NSIndexPath* indexPath = [self.delegate indexPathForPagesCollectionViewCell:self];
            CGPoint contentOffset = [self.delegate contentOffsetForPagesCollectionViewCell:self];
            CGFloat moveY = contentOffset.y - (WKPagesCollectionViewPageSpacing)*indexPath.row;
            CATransform3D moveTransform = CATransform3DMakeTranslation(0.0, moveY, 0.0);
            self.layer.transform = moveTransform;

        }
            break;
        case WKPagesCollectionViewCellStateBackToTop: {
            self.normalTransform = self.layer.transform;
            _scrollView.scrollEnabled = NO;
            _closeButton.hidden = NO;
            CATransform3D rotateTransform = WKFlipCATransform3DPerspectSimpleWithRotate(HighLightRotateAngle);
            CATransform3D moveTransform = CATransform3DMakeTranslation(0, -1*pageHeight, 0.0);
            self.layer.transform=CATransform3DConcat(rotateTransform, moveTransform);
        }
            break;
        case WKPagesCollectionViewCellStateBackToBottom: {
            self.normalTransform = self.layer.transform;
            _scrollView.scrollEnabled = NO;
            _closeButton.hidden = NO;
            CATransform3D rotateTransform = WKFlipCATransform3DPerspectSimpleWithRotate(HighLightRotateAngle);
            CATransform3D moveTransform = CATransform3DMakeTranslation(0.0, pageHeight, 0.0);
            self.layer.transform = CATransform3DConcat(rotateTransform, moveTransform);
        }
            break;
        case WKPagesCollectionViewCellStateNormal: {
            self.layer.transform = self.normalTransform;
            _scrollView.scrollEnabled = YES;
            _closeButton.hidden = NO;
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.state == WKPagesCollectionViewCellStateNormal) {
        CGFloat slideDistance = scrollView.frame.size.width / 6;
        if (scrollView.contentOffset.x >= slideDistance) {
            [self closeButtonTapped:nil];
        }
    }
}

@end
