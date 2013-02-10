//
//  PhysicsObject.h
//  
//
//  Created by Jon Manning on 7/02/13.
//
//

#import "CCPhysicsSprite.h"
#import "PhysicsLayer.h"

@interface PhysicsObject : CCPhysicsSprite <CCTouchOneByOneDelegate>

@property (unsafe_unretained) id<CPPhysicsDelegate> physicsDelegate;
@property (nonatomic, assign) BOOL draggable;

@end
