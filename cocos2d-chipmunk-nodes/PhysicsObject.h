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

// Override this method to receive notifications of collisions with objects
- (void) objectDidCollideWithObject:(PhysicsObject*)otherObject collisionPhase:(CollisionPhase)phase arbiter:(cpArbiter*)collisionArbiter;

@end
