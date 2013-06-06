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

@property (weak) id<CPPhysicsDelegate> physicsDelegate;
@property (nonatomic, assign) BOOL draggable;

// Override this method to receive notifications of collisions with objects
- (void) objectDidCollideWithObject:(PhysicsObject*)otherObject collisionPhase:(CollisionPhase)phase arbiter:(cpArbiter*)collisionArbiter;

// By default, destroys the body and associated shapes. This is called after simulation is complete, so cpSpaceRemoveBody etc will work.
- (void) objectWasRemovedFromSpace;

// Called every frame, before physics is applied.
- (void) objectWillUpdatePhysics:(ccTime)deltaTime;

- (BOOL) shouldCollideWithBody:(cpBody*)body;

@property (strong) NSString* identifier;
@property (nonatomic, assign, getter = isDragging) BOOL dragging;

- (void) stopPhysics;

@end
