//
//  MTCollectionViewLayout.m
//  TestCollectionViewLayout
//
//  Created by huangluyang on 15/7/30.
//  Copyright (c) 2015年 Luyang Huang. All rights reserved.
//

#import "MTCollectionViewLayout.h"

NSString * const MTCollectionViewSupplementaryViewColumnHeader = @"com.hly.mt.supplementary";

@interface MTCollectionViewLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext

@property (nonatomic, assign) BOOL keepCellsLayoutAttributes;
@property (nonatomic, assign) BOOL keepSupplementaryViewsLayoutAttributes;

@end

@implementation MTCollectionViewLayoutInvalidationContext

@end

@interface MTCollectionViewLayout ()

@property (nonatomic, assign) CGSize computedContentSize;
@property (nonatomic, strong) NSArray *attributesForCells;
@property (nonatomic, strong) NSArray *attributesForSupplementaryViews;

@property (nonatomic, assign) CGFloat currentLayoutPointX;
@property (nonatomic, assign) CGFloat currentLayoutPointY;
@property (nonatomic, assign) CGFloat lastItemHeight;   // 用于正确换行
@property (nonatomic, strong) NSMutableDictionary *headerVerticalPositions; // 用于定位header

@end

@implementation MTCollectionViewLayout

#pragma mark - Override Layout
- (void)prepareLayout
{
    [super prepareLayout];
    
    [self attributesForCells];
    [self attributesForSupplementaryViews];
}

- (CGSize)collectionViewContentSize
{
    return self.computedContentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributes = [NSMutableArray new];
    
    [layoutAttributes addObjectsFromArray:[self.attributesForCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *attributes, NSDictionary *bindings) {
        return (CGRectIntersectsRect(rect, attributes.frame));
    }]]];
    
    [layoutAttributes addObjectsFromArray:[self.attributesForSupplementaryViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *attributes, NSDictionary *bindings) {
        return (CGRectIntersectsRect(rect, attributes.frame));
    }]]];
    
    return [NSArray arrayWithArray:layoutAttributes];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *currentItemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    NSInteger totalColumnSliceCount = [self.layoutDelegate mt_collectionViewLayout:self numberOfColumnSliceForSection:indexPath.section];
    NSInteger columnSliceCount = [self.layoutDelegate mt_collectionViewLayout:self columnSliceCountForItemAtIndexPath:indexPath];
    NSInteger rowSliceCount = [self.layoutDelegate mt_collectionViewLayout:self rowSliceCountForItemAtIndexPath:indexPath];
    CGFloat horizontalSpacing = [self.layoutDelegate mt_collectionViewLayout:self horizontalSpaceForSection:indexPath.section];
    CGFloat verticalSpacing = [self.layoutDelegate mt_collectionViewLayout:self verticalSpaceForSection:indexPath.section];
    UIEdgeInsets insets = [self.layoutDelegate mt_collectionViewLayout:self contentIndsetsForSection:indexPath.section];
    CGFloat rate = [self.layoutDelegate mt_collectionViewLayout:self rateOfHeightWidthForUnitForSection:indexPath.section];
    
    if (self.currentLayoutPointX == 0) {
        self.currentLayoutPointX += insets.left;
    } else {
        self.currentLayoutPointX += horizontalSpacing;
    }
    
    if (self.currentLayoutPointY == 0) {
        self.currentLayoutPointY += insets.top;
    }
    
    CGFloat unitWidth = (CGRectGetWidth(self.collectionView.frame) - insets.left - insets.right - horizontalSpacing * (totalColumnSliceCount - 1)) / totalColumnSliceCount;
    CGFloat unitHeight = unitWidth * rate;
    
    CGFloat width = unitWidth * columnSliceCount + horizontalSpacing * (columnSliceCount - 1);
    CGFloat height = unitHeight * rowSliceCount + verticalSpacing * (rowSliceCount - 1);
    
    BOOL isFirstItem = indexPath.item == 0;
    BOOL isLastItem = indexPath.item == [self.collectionView numberOfItemsInSection:indexPath.section] - 1;
    BOOL showHeadder = [self.layoutDelegate respondsToSelector:@selector(mt_collectionViewLayout:heightForHeaderInSection:)] && [self.layoutDelegate mt_collectionViewLayout:self heightForHeaderInSection:indexPath.section] > 0;
    
    CGFloat headerHeight = 0;
    if (showHeadder) {
        if (isFirstItem) {
            headerHeight = [self.layoutDelegate mt_collectionViewLayout:self heightForHeaderInSection:indexPath.section];
            CGFloat headerY = 0;
            if (indexPath.section > 0) {
                headerY = self.currentLayoutPointY + self.lastItemHeight;
            }
            [self.headerVerticalPositions setObject:@(headerY) forKey:[NSString stringWithFormat:@"section%ld", (long)indexPath.section]];
        }
        self.currentLayoutPointY += headerHeight;
    }
    
    CGFloat maxX = CGRectGetWidth(self.collectionView.frame) - insets.right;
    BOOL needLineFeed = (isFirstItem && indexPath.section != 0) || self.currentLayoutPointX + width > maxX;
    if (needLineFeed) {
        self.currentLayoutPointX = insets.left;
        self.currentLayoutPointY += self.lastItemHeight;
        if ((isLastItem || isFirstItem) && showHeadder) {
            self.currentLayoutPointY += insets.bottom;
        } else {
            self.currentLayoutPointY += verticalSpacing;
        }
    }
    
    currentItemAttributes.frame = CGRectMake(self.currentLayoutPointX, self.currentLayoutPointY, width, height);
    self.currentLayoutPointX += width;
    self.lastItemHeight = height;
    BOOL isLastSection = indexPath.section == [self.collectionView numberOfSections] - 1;
    if (isLastSection && isLastItem) {
        self.currentLayoutPointY += insets.bottom;
    }
    
    CGFloat currentContentHeight = self.currentLayoutPointY + height;
    if (self.computedContentSize.height < currentContentHeight) {
        self.computedContentSize = CGSizeMake(self.computedContentSize.width, currentContentHeight);
    }
    
    if (self.computedContentSize.width == 0) {
        self.computedContentSize = CGSizeMake(CGRectGetWidth(self.collectionView.frame), self.computedContentSize.height);
    }
    
    return currentItemAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *currentItemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    if ([kind isEqualToString:MTCollectionViewSupplementaryViewColumnHeader]) {
        
        CGFloat height = [self.layoutDelegate mt_collectionViewLayout:self heightForHeaderInSection:indexPath.section];
        CGFloat width = CGRectGetWidth(self.collectionView.frame);
        CGFloat x = 0;
        CGFloat y = [[self.headerVerticalPositions objectForKey:[NSString stringWithFormat:@"section%ld", (long)indexPath.section]] floatValue];
        
        BOOL sticky = [self.layoutDelegate respondsToSelector:@selector(mt_collectionViewLayout:stickyHeadersInSection:)] && [self.layoutDelegate mt_collectionViewLayout:self stickyHeadersInSection:indexPath.section];
        if (sticky) {
            CGFloat stickyY = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
            CGFloat maxY = stickyY;
            if (indexPath.section < [self.collectionView numberOfSections] - 1) {
                NSNumber *nextPosition = nil;
                for (int i = (int)indexPath.section; i < [self.collectionView numberOfSections]; i++) {
                    nextPosition = [self.headerVerticalPositions objectForKey:[NSString stringWithFormat:@"section%ld", (long)(indexPath.section + 1)]];
                    if (nextPosition) {
                        break;
                    }
                }
                if (nextPosition) {
                    CGFloat nextY = [nextPosition floatValue];
                    CGFloat nextHeight = [self.layoutDelegate mt_collectionViewLayout:self heightForHeaderInSection:indexPath.section + 1];
                    maxY = nextY - nextHeight;
                } else {
                    maxY = stickyY;
                }
            }
            
            if (y < stickyY) {
                y = MIN(maxY, stickyY);
            }
        }
        
        currentItemAttributes.frame = CGRectMake(x, y, width, height);
        currentItemAttributes.zIndex = 101;
    }
    
    return currentItemAttributes;
}

#pragma mark - Override Layout invalidation

+ (Class)invalidationContextClass
{
    return [MTCollectionViewLayoutInvalidationContext class];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1 &&
        [self stickyHeadersInAnySection]) {
        _attributesForSupplementaryViews = nil;
    }
    
    return YES;
}

- (void)invalidateLayoutWithContext:(MTCollectionViewLayoutInvalidationContext *)context
{
    [super invalidateLayoutWithContext:context];
    
    if (![(MTCollectionViewLayoutInvalidationContext *)context keepCellsLayoutAttributes]) {
        _computedContentSize = CGSizeZero;
        if (_attributesForCells) {
            _attributesForCells = nil;
        }
    }
    
    if (![(MTCollectionViewLayoutInvalidationContext *)context keepSupplementaryViewsLayoutAttributes]) {
        if (_attributesForSupplementaryViews) {
            _attributesForSupplementaryViews = nil;
        }
    }
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds
{
    MTCollectionViewLayoutInvalidationContext *context = (MTCollectionViewLayoutInvalidationContext *)[super invalidationContextForBoundsChange:newBounds];
    
    context.keepCellsLayoutAttributes = YES;
    context.keepSupplementaryViewsLayoutAttributes = ![self stickyHeadersInAnySection];
    
    return context;
}

#pragma mark - Private Methods
- (BOOL)stickyHeadersInAnySection
{
    BOOL sticky = [self.layoutDelegate respondsToSelector:@selector(mt_collectionViewLayout:stickyHeadersInSection:)];
    if (!sticky) {
        return NO;
    }
    
    for (int i = 0; i < [self.collectionView numberOfSections]; i++) {
        if ([self.layoutDelegate mt_collectionViewLayout:self stickyHeadersInSection:i]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Setters & Getters
- (NSArray *)attributesForCells
{
    @synchronized(self) {
        if (!_attributesForCells) {
            NSMutableArray *layoutAttributes = [NSMutableArray new];
            NSUInteger numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
            for (NSUInteger sectionIdx = 0; sectionIdx < numberOfSections; sectionIdx++) {
                NSUInteger numberOfItemsInSection = [self.collectionView.dataSource collectionView:self.collectionView
                                                                            numberOfItemsInSection:sectionIdx];
                for (NSUInteger itemIdx = 0; itemIdx < numberOfItemsInSection; itemIdx++) {
                    [layoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:itemIdx
                                                                                                             inSection:sectionIdx]]];
                }
            }
            _attributesForCells = [NSArray arrayWithArray:layoutAttributes];
        }
        return _attributesForCells;
    }
}

- (NSArray *)attributesForSupplementaryViews
{
    @synchronized(self) {
        if (!_attributesForSupplementaryViews) {
            NSMutableArray *layoutAttributes = [NSMutableArray new];
            NSUInteger sectionsCount = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
            for (NSUInteger sectionIdx = 0; sectionIdx < sectionsCount; sectionIdx++) {
                
                BOOL hasColumnHeader = [self.layoutDelegate respondsToSelector:@selector(mt_collectionViewLayout:heightForHeaderInSection:)] && [self.layoutDelegate mt_collectionViewLayout:self heightForHeaderInSection:sectionIdx] > 0;
                if (hasColumnHeader) {
                    [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:MTCollectionViewSupplementaryViewColumnHeader
                                                                                     atIndexPath:[NSIndexPath indexPathForItem:0
                                                                                                                     inSection:sectionIdx]]];
                }
            }
            _attributesForSupplementaryViews = [NSArray arrayWithArray:layoutAttributes];
        }
        return _attributesForSupplementaryViews;
    }
}

- (NSMutableDictionary *)headerVerticalPositions
{
    if (!_headerVerticalPositions) {
        _headerVerticalPositions = [NSMutableDictionary dictionaryWithCapacity:[self.collectionView numberOfSections]];
    }
    return _headerVerticalPositions;
}

@end
