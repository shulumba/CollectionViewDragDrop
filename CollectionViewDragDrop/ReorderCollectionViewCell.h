//
//  ReorderCollectionViewCell.h
//  CollectionViewDragDrop
//
//  Created by Shulumba Igor on 3/14/17.
//  Copyright © 2017 Shulumba Igor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReorderCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id representedObject;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
