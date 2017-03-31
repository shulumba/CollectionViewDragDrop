//
//  ViewController.m
//  CollectionViewDragDrop
//
//  Created by Shulumba Igor on 3/14/17.
//  Copyright © 2017 Shulumba Igor. All rights reserved.
//

#import "ViewController.h"
#import "ReorderCollectionViewCell.h"

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray *elements;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupElements];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.elements count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ReorderCollectionViewCell class]) forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(ReorderCollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.representedObject = self.elements[indexPath.row];
}

#pragma mark - NBReorderCollectionViewDelegate

- (void)finishReorderingItem:(id)fromItem toItemAtIndexPath:( NSIndexPath *)toIndexPath needReorder:(BOOL)needReorder {
    if (needReorder) {
        NSLog(@"Reorder");
    } else {
        NSLog(@"Copy or Move");
    }
}

#pragma mark - private

- (void)setupElements {
    self.elements = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++) {
        [self.elements addObject:[NSString stringWithFormat:@"%ld", i]];
    }
    [self.collectionView reloadData];
}

@end
