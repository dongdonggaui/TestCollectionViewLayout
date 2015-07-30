//
//  MTCollectionViewLayout.h
//  TestCollectionViewLayout
//
//  Created by huangluyang on 15/7/30.
//  Copyright (c) 2015年 Luyang Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const MTCollectionViewSupplementaryViewColumnHeader;

@protocol MTCollectionViewLayoutDelegate <NSObject>

- (NSInteger)numberOfColumnSliceForSection:(NSInteger)section;
- (CGFloat)rateOfHeightWidthForUnitForSection:(NSInteger)section;
- (NSInteger)columnSliceCountForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)rowSliceCountForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)horizontalSpaceForSection:(NSInteger)section;
- (CGFloat)verticalSpaceForSection:(NSInteger)section;
- (UIEdgeInsets)contentIndsetsForSection:(NSInteger)section;

@optional
- (BOOL)stickyHeadersInSection:(NSUInteger)section;
- (CGFloat)heightForHeaderInSection:(NSUInteger)section;

@end

@interface MTCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, weak) id<MTCollectionViewLayoutDelegate> layoutDelegate;

@end
