//
//  MTCollectionViewLayout.h
//  TestCollectionViewLayout
//
//  Created by huangluyang on 15/7/30.
//  Copyright (c) 2015年 Luyang Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const MTCollectionViewSupplementaryViewColumnHeader;

@class MTCollectionViewLayout;

@protocol MTCollectionViewLayoutDelegate <NSObject>

- (NSInteger)mt_collectionViewLayout:(MTCollectionViewLayout *)layout numberOfColumnSliceForSection:(NSInteger)section;
- (CGFloat)mt_collectionViewLayout:(MTCollectionViewLayout *)layout rateOfHeightWidthForUnitForSection:(NSInteger)section;
- (NSInteger)mt_collectionViewLayout:(MTCollectionViewLayout *)layout columnSliceCountForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)mt_collectionViewLayout:(MTCollectionViewLayout *)layout rowSliceCountForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)mt_collectionViewLayout:(MTCollectionViewLayout *)layout horizontalSpaceForSection:(NSInteger)section;
- (CGFloat)mt_collectionViewLayout:(MTCollectionViewLayout *)layout verticalSpaceForSection:(NSInteger)section;
- (UIEdgeInsets)mt_collectionViewLayout:(MTCollectionViewLayout *)layout contentIndsetsForSection:(NSInteger)section;

@optional
- (BOOL)mt_collectionViewLayout:(MTCollectionViewLayout *)layout stickyHeadersInSection:(NSUInteger)section;
- (CGFloat)mt_collectionViewLayout:(MTCollectionViewLayout *)layout heightForHeaderInSection:(NSUInteger)section;

@end

@interface MTCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, weak) id<MTCollectionViewLayoutDelegate> layoutDelegate;

@end
