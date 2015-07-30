//
//  ViewController.m
//  TestCollectionViewLayout
//
//  Created by huangluyang on 15/7/30.
//  Copyright (c) 2015年 Luyang Huang. All rights reserved.
//

#import "ViewController.h"
#import "MTCollectionViewLayout.h"

@interface ViewController () <MTCollectionViewLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:MTCollectionViewSupplementaryViewColumnHeader withReuseIdentifier:@"header"];
    MTCollectionViewLayout *layout = [[MTCollectionViewLayout alloc] init];
    layout.layoutDelegate = self;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return 6;
    } else if (section == 1) {
        return 1;
    } else {
        return 40;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor orangeColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:MTCollectionViewSupplementaryViewColumnHeader]) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        if (indexPath.section == 0) {
            view.backgroundColor = [UIColor brownColor];
        } else if (indexPath.section == 1) {
            view.backgroundColor = [UIColor lightGrayColor];
        } else {
            view.backgroundColor = [UIColor whiteColor];
        }
        return view;
    }
    return nil;
}

#pragma mark - MTCollectionViewLayoutDelegate
- (NSInteger)mt_collectionViewLayout:(MTCollectionViewLayout *)layout numberOfColumnSliceForSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)mt_collectionViewLayout:(MTCollectionViewLayout *)layout rateOfHeightWidthForUnitForSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)mt_collectionViewLayout:(MTCollectionViewLayout *)layout columnSliceCountForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 5;
    } else if (indexPath.section == 1) {
        return 10;
    } else {
        return 2;
    }
}

- (NSInteger)mt_collectionViewLayout:(MTCollectionViewLayout *)layout rowSliceCountForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 2;
    } else if (indexPath.section == 1) {
        return 5;
    } else {
        return 2;
    }
}

- (CGFloat)mt_collectionViewLayout:(MTCollectionViewLayout *)layout horizontalSpaceForSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)mt_collectionViewLayout:(MTCollectionViewLayout *)layout verticalSpaceForSection:(NSInteger)section
{
    return 5;
}

- (UIEdgeInsets)mt_collectionViewLayout:(MTCollectionViewLayout *)layout contentIndsetsForSection:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (BOOL)mt_collectionViewLayout:(MTCollectionViewLayout *)layout stickyHeadersInSection:(NSUInteger)section
{
    return YES;
}

- (CGFloat)mt_collectionViewLayout:(MTCollectionViewLayout *)layout heightForHeaderInSection:(NSUInteger)section
{
    return 44;
}

@end
