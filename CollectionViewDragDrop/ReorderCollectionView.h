//
//  ReorderCollectionView.h
//  CollectionViewDragDrop
//
//  Created by Shulumba Igor on 3/14/17.
//  Copyright © 2017 Shulumba Igor. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReorderCollectionViewDelegate <UICollectionViewDelegate>

- (void)finishReorderingItem:(id)fromItem toItemAtIndexPath:(NSIndexPath *)toIndexPath needReorder:(BOOL)needReorder;

@end

@interface ReorderCollectionView : UICollectionView

@property (nonatomic, weak) id <ReorderCollectionViewDelegate> delegate;

@end
