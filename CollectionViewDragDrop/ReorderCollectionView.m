//
//  ReorderCollectionView.m
//  CollectionViewDragDrop
//
//  Created by Shulumba Igor on 3/14/17.
//  Copyright © 2017 Shulumba Igor. All rights reserved.
//

#import "ReorderCollectionView.h"
#import "SwapDescription.h"
#import "ReorderCollectionViewCell.h"

@interface ReorderCollectionView()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSIndexPath *interactiveIndexPath;
@property (strong, nonatomic) UIView *interactiveView;
@property (weak, nonatomic) UICollectionViewCell *interactiveCell;
@property (strong, nonatomic) NSMutableSet <SwapDescription *>*swapSet;
@property (assign, nonatomic) CGPoint previousPoint;
@property (assign, nonatomic) BOOL isMoving;
@property (assign, nonatomic) BOOL needToEndInteractiveOnFinishAnimation;

@end

@implementation ReorderCollectionView

@dynamic delegate;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.swapSet = [NSMutableSet set];
    [self setupPanGesture];
}

- (BOOL)beginInteractiveMovementForItemAtIndexPath:(NSIndexPath *)indexPath {
    self.needToEndInteractiveOnFinishAnimation = NO;
    self.interactiveIndexPath = indexPath;
    self.interactiveCell = [self cellForItemAtIndexPath:indexPath];
    if (!self.interactiveCell) {
        return NO;
    }
    
    UIGraphicsBeginImageContext(self.interactiveCell.bounds.size);
    [self.interactiveCell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.interactiveView = [[UIImageView alloc] initWithImage:cellImage];
    self.interactiveView.frame = self.interactiveCell.frame;
    [self addSubview:self.interactiveView];
    
    [self bringSubviewToFront:self.interactiveView];
    self.interactiveCell.hidden = YES;
    
    return YES;
}

- (void)updateInteractiveMovementTargetPosition:(CGPoint)targetPosition {
    
    CGPoint moveToPoint = CGPointZero;
    if ([self shouldSwap:targetPosition moveToPoint:&moveToPoint]) {
        NSIndexPath *hoverIndexPath = [self indexPathForItemAtPoint:moveToPoint];
        NSIndexPath *interactiveIndexPath = self.interactiveIndexPath;
        if (hoverIndexPath && interactiveIndexPath) {
            SwapDescription *swapDescription = [SwapDescription swapDescriptionWithFirstItem:interactiveIndexPath.item secondItem:hoverIndexPath.item];
            if (![self.swapSet containsObject:swapDescription]) {
                [self.swapSet addObject:swapDescription];
                self.isMoving = YES;
                [self performBatchUpdates:^{
                    [self moveItemAtIndexPath:interactiveIndexPath toIndexPath:hoverIndexPath];
                    [self moveItemAtIndexPath:hoverIndexPath toIndexPath:interactiveIndexPath];
                } completion:^(BOOL finished) {
                    [self.swapSet removeObject:swapDescription];
                    self.interactiveIndexPath = hoverIndexPath;
                    self.isMoving = NO;
                    if (self.needToEndInteractiveOnFinishAnimation) {
                        [self endInteractiveMovement];
                    }
                }];
            }
        }
    }
    self.interactiveView.center = targetPosition;
    self.previousPoint = targetPosition;
}

- (void)endInteractiveMovement {
    if (self.isMoving) {
        self.needToEndInteractiveOnFinishAnimation = YES;
        return;
    }
    
    id fromItem = [(ReorderCollectionViewCell *)self.interactiveCell representedObject];
    [self.delegate finishReorderingItem:fromItem toItemAtIndexPath:[self moveToIndexPath] needReorder:[self needReorderItems]];
    [self cleanup];
}

- (void)cancelInteractiveMovement {
    [self cleanup];
    [self reloadData];
}

- (void)cleanup {
    self.interactiveCell.hidden = NO;
    [self.interactiveView removeFromSuperview];
    self.interactiveView = nil;
    self.interactiveCell = nil;
    self.interactiveIndexPath = nil;
    self.previousPoint = CGPointZero;
    [self.swapSet removeAllObjects];
}

#pragma mark - private

- (UICollectionViewCell *)moveToCell {
    NSIndexPath *indexPath = [self moveToIndexPath];
    ReorderCollectionViewCell *cell = (ReorderCollectionViewCell *)[self cellForItemAtIndexPath:indexPath];
    return cell;
}

- (BOOL)needReorderItems {
    
    if (self.isMoving) {
        return YES;
    }
    
    ReorderCollectionViewCell *cell = (ReorderCollectionViewCell *)[self moveToCell];
    if (![cell isMemberOfClass:[ReorderCollectionViewCell class]]) {
        return YES;
    }
    
    BOOL needReorderItems = [[cell representedObject] isEqual: [(ReorderCollectionViewCell *)self.interactiveCell representedObject]];
    return needReorderItems;
}

- (BOOL)shouldSwap:(CGPoint)targetPosition moveToPoint:(CGPoint *)moveToPoint{
    if (self.isMoving) {
        return NO;
    }
    if (!self.interactiveCell) {
        return NO;
    }
    
    if ([self shouldMoveLeft:targetPosition moveToPoint:moveToPoint]) {
        return YES;
    }
    else if ([self shouldMoveRight:targetPosition moveToPoint:moveToPoint]) {
        return YES;
    }
    else if ([self shouldMoveDown:targetPosition moveToPoint:moveToPoint]) {
        return YES;
    }
    else if ([self shouldMoveUp:targetPosition moveToPoint:moveToPoint]) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldMoveLeft:(CGPoint)targetPosition moveToPoint:(CGPoint *)moveToPoint{
    
    if (self.previousPoint.x < targetPosition.x) {
        return NO;
    }
    
    CGRect movingFrame = [[self interactiveView] frame];
    
    CGFloat originXInteractive = CGRectGetMinX(movingFrame);
    CGFloat originYInteractive = CGRectGetMidY(movingFrame);
    
    NSIndexPath *currentIndexPath = [self indexPathForItemAtPoint:CGPointMake(originXInteractive, originYInteractive)];
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:currentIndexPath];
    CGRect currentFrame = [cell frame];
    
    BOOL canMove = [self canMoveHorizontalItemAtFrame:movingFrame toItemAtFrame:currentFrame];
    if (canMove) {
        *moveToPoint = CGPointMake(CGRectGetMidX(currentFrame), CGRectGetMidY(currentFrame));
    }
    return canMove;
}

- (BOOL)shouldMoveRight:(CGPoint)targetPosition moveToPoint:(CGPoint *)moveToPoint{
    
    if (self.previousPoint.x > targetPosition.x) {
        return NO;
    }
    
    CGRect movingFrame = [[self interactiveView] frame];
    
    CGFloat originXInteractive = CGRectGetMaxX(movingFrame);
    CGFloat originYInteractive = CGRectGetMidY(movingFrame);
    
    NSIndexPath *currentIndexPath = [self indexPathForItemAtPoint:CGPointMake(originXInteractive, originYInteractive)];
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:currentIndexPath];
    CGRect currentFrame = [cell frame];
    
    BOOL canMove = [self canMoveHorizontalItemAtFrame:movingFrame toItemAtFrame:currentFrame];
    if (canMove) {
        *moveToPoint = CGPointMake(CGRectGetMidX(currentFrame), CGRectGetMidY(currentFrame));
    }
    return canMove;
}

- (BOOL)shouldMoveDown:(CGPoint)targetPosition moveToPoint:(CGPoint *)moveToPoint {
    if (self.previousPoint.y > targetPosition.y) {
        return NO;
    }
    CGRect movingFrame = [[self interactiveView] frame];
    
    CGFloat originXInteractive = CGRectGetMidX(movingFrame);
    CGFloat originYInteractive = CGRectGetMaxY(movingFrame);
    
    NSIndexPath *currentIndexPath = [self indexPathForItemAtPoint:CGPointMake(originXInteractive, originYInteractive)];
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:currentIndexPath];
    CGRect currentFrame = [cell frame];
    
    BOOL canMove = [self canMoveVerticalItemAtFrame:movingFrame toItemAtFrame:currentFrame];
    if (canMove) {
        *moveToPoint = CGPointMake(CGRectGetMidX(currentFrame), CGRectGetMidY(currentFrame));
    }
    return canMove;
}

- (BOOL)shouldMoveUp:(CGPoint)targetPosition moveToPoint:(CGPoint *)moveToPoint {
    if (self.previousPoint.y < targetPosition.y) {
        return NO;
    }
    
    CGRect movingFrame = [[self interactiveView] frame];
    
    CGFloat originXInteractive = CGRectGetMidX(movingFrame);
    CGFloat originYInteractive = CGRectGetMinY(movingFrame);
    
    NSIndexPath *currentIndexPath = [self indexPathForItemAtPoint:CGPointMake(originXInteractive, originYInteractive)];
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:currentIndexPath];
    CGRect currentFrame = [cell frame];
    
    BOOL canMove = [self canMoveVerticalItemAtFrame:movingFrame toItemAtFrame:currentFrame];
    if (canMove) {
        *moveToPoint = CGPointMake(CGRectGetMidX(currentFrame), CGRectGetMidY(currentFrame));
    }
    return canMove;
}

- (BOOL)canMoveHorizontalItemAtFrame:(CGRect)previousCellFrame toItemAtFrame:(CGRect)interativeFrame {
    CGRect instersection = CGRectIntersection(previousCellFrame, interativeFrame);
    CGSize moveOffsetSize = CGSizeMake(30, 10);
    BOOL canMove = instersection.size.width < moveOffsetSize.width && instersection.size.height > (previousCellFrame.size.height - moveOffsetSize.height);
    return canMove;
}

- (BOOL)canMoveVerticalItemAtFrame:(CGRect)previousCellFrame toItemAtFrame:(CGRect)interativeFrame {
    CGRect instersection = CGRectIntersection(previousCellFrame, interativeFrame);
    CGSize moveOffsetSize = CGSizeMake(15, 30);
    BOOL canMove = (instersection.size.width > (previousCellFrame.size.width - moveOffsetSize.width))  && instersection.size.height < moveOffsetSize.height;
    return canMove;
}

- (void)setupPanGesture {
    UILongPressGestureRecognizer *collectionViewLongGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleMove:)];
    collectionViewLongGesture.delegate = self;
    collectionViewLongGesture.delaysTouchesBegan = YES;
    collectionViewLongGesture.minimumPressDuration = 0.2;
    [self addGestureRecognizer:collectionViewLongGesture];
}

- (void)handleMove:(UIPanGestureRecognizer *)panRecognizer {
    
    CGPoint locationPoint = [panRecognizer locationInView:self];
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self indexPathForItemAtPoint:locationPoint];
        if (indexPath) {
            [self beginInteractiveMovementForItemAtIndexPath:indexPath];
        }
    }
    
    else if (panRecognizer.state == UIGestureRecognizerStateChanged) {
        [self updateInteractiveMovementTargetPosition:locationPoint];
    }
    
    else if (panRecognizer.state == UIGestureRecognizerStateEnded) {
        BOOL canEndInteraction = ([self moveToIndexPath] != nil) && (self.interactiveCell != nil);
        if (!canEndInteraction) {
            [self cancelInteractiveMovement];
        } else {
            [self endInteractiveMovement];
        }
    } else {
        [self cancelInteractiveMovement];
    }
}

- (NSIndexPath *)moveToIndexPath {
    return [self indexPathForItemAtPoint:self.interactiveView.center];
}

@end
