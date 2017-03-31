//
//  SwapDescription.h
//  CollectionViewDragDrop
//
//  Created by Shulumba Igor on 3/14/17.
//  Copyright © 2017 Shulumba Igor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwapDescription : NSObject

@property (assign, nonatomic) NSInteger firstItem;
@property (assign, nonatomic) NSInteger secondItem;

+ (instancetype)swapDescriptionWithFirstItem:(NSInteger)firstItem secondItem:(NSInteger)secondItem;

- (NSInteger)hashValue;

@end
