//
//  ReorderCollectionViewCell.m
//  CollectionViewDragDrop
//
//  Created by Shulumba Igor on 3/14/17.
//  Copyright © 2017 Shulumba Igor. All rights reserved.
//

#import "ReorderCollectionViewCell.h"

@implementation ReorderCollectionViewCell

- (void)setRepresentedObject:(id)representedObject {
    [self.titleLabel setText:representedObject];
    _representedObject = representedObject;
}

@end
