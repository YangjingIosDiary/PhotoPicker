//
//  PhotoPerviewController.m
//  Project2-PhotoPicker-OC
//
//  Created by YangJing on 2018/3/19.
//  Copyright © 2018年 YangJing. All rights reserved.
//


#import "PhotoPerviewController.h"
#import "PhotoCell.h"
#import "PhotoThumbnailCell.h"

@interface PhotoPerviewController () <UICollectionViewDelegate, UICollectionViewDataSource, PhotoCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) UICollectionView *thumCollectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *thumLayout;

@property (nonatomic, strong) PhotoThumbnailCell *selectedThumbnailCell;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) UIButton *selectedBtn;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *confirmBtn;

@end

@implementation PhotoPerviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addSubview];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

//MARK: - private methods
- (void)photoSelectedAction:(UIButton *)btn {
    if (self.currentIndex >= self.dataArray.count) return;
    PhotoModel *model = self.dataArray[self.currentIndex];
    if (model.selectedIndex > 0) {
        if ([self.selectArray containsObject:model]) {
            [self.selectArray removeObject:model];
            
        } else {
            NSLog(@"yangjing_%@: data error", NSStringFromClass([self class]));
        }
        
        self.selectedBtn.selected = NO;
        model.selectedIndex = 0;
        
    } else {
        self.selectedBtn.selected = YES;
        model.selectedIndex = self.selectArray.count;
    }
    
}

- (void)checkTopView {
    if (self.currentIndex >= self.dataArray.count) return;
    
    PhotoModel *model = self.dataArray[self.currentIndex];
    self.selectedBtn.selected = model.selectedIndex > 0;
    
    if (model.selectedIndex > 0) {
        self.selectedBtn.backgroundColor = [UIColor greenColor];
        self.selectedBtn.layer.borderWidth = 0;
        [self.selectedBtn setTitle:[NSString stringWithFormat:@"%ld", (long)model.selectedIndex] forState:UIControlStateSelected];
        
        //thumCollectionView 联动
        if ([self.selectArray containsObject:model]) {
            NSInteger index = [self.selectArray indexOfObject:model];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            PhotoThumbnailCell *thumCell = (PhotoThumbnailCell *)[self.thumCollectionView cellForItemAtIndexPath:indexPath];
            if (![self.selectedThumbnailCell isEqual:thumCell]) {
                self.selectedThumbnailCell.isSelected = NO;
                thumCell.isSelected = YES;
                self.selectedThumbnailCell = thumCell;
            }
            
            [self.thumCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
        
    } else {
        self.selectedBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        self.selectedBtn.layer.borderWidth = 1;
        [self.selectedBtn setTitle:@"" forState:UIControlStateNormal];
    }
}

//MARK: - photocellDelegate
- (void)photoCell:(PhotoCell *)cell singleTapAction:(UITapGestureRecognizer *)tap {
    self.bottomView.hidden = !self.bottomView.hidden;
    
    if (self.bottomView.hidden) {
        self.navigationController.navigationBar.hidden = YES;
        self.thumCollectionView.hidden = YES;

    } else {
        self.navigationController.navigationBar.hidden = NO;
        self.thumCollectionView.hidden = self.selectArray.count <= 0;

    }
}

//MARK: - collectionViewDatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([collectionView isEqual:self.thumCollectionView]) {
        return self.selectArray.count;
    }
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.thumCollectionView]) {
        PhotoModel *model = self.selectArray[indexPath.row];
        PhotoThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoThumbnailCellID forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }
    
    PhotoModel *model = self.dataArray[indexPath.row];
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellID forIndexPath:indexPath];
    cell.model = model;
    cell.delegate = self;
    return cell;
}

//MARK: - collectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.thumCollectionView]) {
        return;
    }
    PhotoCell *photoCell = (PhotoCell *)cell;
    [photoCell setCellZoomScale:1 animated:NO];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.thumCollectionView]) {
        PhotoThumbnailCell *cell = (PhotoThumbnailCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        if (![self.selectedThumbnailCell isEqual:cell]) {
            self.selectedThumbnailCell.isSelected = NO;
            cell.isSelected = YES;
            self.selectedThumbnailCell = cell;
            
        }
        
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        
        //self.collectionView 联动
        PhotoModel *model = self.selectArray[indexPath.row];
        if ([self.dataArray containsObject:model]) {
            self.currentIndex = [self.dataArray indexOfObject:model];
            [self.collectionView setContentOffset:CGPointMake((CGRectGetWidth([UIScreen mainScreen].bounds)+20)*self.currentIndex, -64)];
            
            self.selectedBtn.selected = model.selectedIndex > 0;
            
            if (model.selectedIndex > 0) {
                self.selectedBtn.backgroundColor = [UIColor greenColor];
                self.selectedBtn.layer.borderWidth = 0;
                [self.selectedBtn setTitle:[NSString stringWithFormat:@"%ld", (long)model.selectedIndex] forState:UIControlStateSelected];

            } else {
                self.selectedBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
                self.selectedBtn.layer.borderWidth = 1;
                [self.selectedBtn setTitle:@"" forState:UIControlStateNormal];
            }
            
        }
        
        return;
    }
}

//MARK: - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isEqual:self.collectionView]) return;
    
    NSInteger index = scrollView.contentOffset.x/CGRectGetWidth([UIScreen mainScreen].bounds);
    if (labs(self.currentIndex - index) != 1) return;
    
    self.currentIndex = index;
    [self checkTopView];
}

- (void)addSubview {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectedBtn];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat confirmWidth = [@"确定" boundingRectWithSize:CGSizeMake(MAXFLOAT, 22) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil].size.width;
    [self.bottomView addSubview:self.confirmBtn];
    self.confirmBtn.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)-confirmWidth-15, 14.5, confirmWidth, 22);
    self.confirmBtn.enabled = NO;
    
    [self.view addSubview:self.collectionView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView setContentOffset:CGPointMake((CGRectGetWidth([UIScreen mainScreen].bounds)+20)*self.currentIndex, -64)];

        [self checkTopView];
    });
    
    [self.view addSubview:self.thumCollectionView];
    self.thumCollectionView.hidden = self.selectArray.count <= 0;
    
    [self.view addSubview:self.bottomView];
    self.bottomView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds)-52, CGRectGetWidth([UIScreen mainScreen].bounds), 52);
}

//MARK: - getter
- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumLineSpacing = 20;
        _layout.minimumInteritemSpacing = 0;
        _layout.itemSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.sectionInset = UIEdgeInsetsMake(-64, 10, 0, 10);
    }
    return _layout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, CGRectGetWidth([UIScreen mainScreen].bounds)+20, CGRectGetHeight([UIScreen mainScreen].bounds)) collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:PhotoCellID];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)thumLayout {
    if (!_thumLayout) {
        _thumLayout = [[UICollectionViewFlowLayout alloc] init];
        _thumLayout.minimumLineSpacing = 20;
        _thumLayout.minimumInteritemSpacing = 0;
        _thumLayout.itemSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)/6.0, CGRectGetWidth([UIScreen mainScreen].bounds)/6.0);
        _thumLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _thumLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    }
    return _thumLayout;
}

- (UICollectionView *)thumCollectionView {
    if (!_thumCollectionView) {
        _thumCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds)-CGRectGetWidth([UIScreen mainScreen].bounds)/6.0-40-52, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds)/6.0+40) collectionViewLayout:self.thumLayout];
        _thumCollectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        _thumCollectionView.delegate = self;
        _thumCollectionView.dataSource = self;
        _thumCollectionView.pagingEnabled = YES;
        [_thumCollectionView registerClass:[PhotoThumbnailCell class] forCellWithReuseIdentifier:PhotoThumbnailCellID];
    }
    return _thumCollectionView;
}

- (UIButton *)selectedBtn {
    if (!_selectedBtn) {
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedBtn addTarget:self action:@selector(photoSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
        _selectedBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _selectedBtn.layer.cornerRadius = 15;
        _selectedBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _selectedBtn.layer.borderWidth = 1;
        _selectedBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_selectedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    }
    return _selectedBtn;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateDisabled];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _confirmBtn.enabled = NO;
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _confirmBtn;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    }
    return _bottomView;
}

@end
