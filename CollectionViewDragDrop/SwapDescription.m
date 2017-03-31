//
//  SwapDescription.m
//  CollectionViewDragDrop
//
//  Created by Shulumba Igor on 3/14/17.
//  Copyright © 2017 Shulumba Igor. All rights reserved.
//

#import "SwapDescription.h"

@implementation SwapDescription

+ (instancetype)swapDescriptionWithFirstItem:(NSInteger)firstItem secondItem:(NSInteger)secondItem {
    SwapDescription *swapDescription = [[SwapDescription alloc] init];
    swapDescription.firstItem = firstItem;
    swapDescription.secondItem = secondItem;
    return swapDescription;
}

- (NSInteger)hashValue {
    return (self.firstItem * 10) + self.secondItem;
}

- (BOOL)isEqual:(SwapDescription *)object {
    return self.firstItem == [object firstItem] && self.secondItem == [object secondItem];
}

@end
