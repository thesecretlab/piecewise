//
//  PhysicsObject.m
//  
//
//  Created by Jon Manning on 7/02/13.
//
//

#import "PhysicsObject.h"
#import "chipmunk.h"

@implementation PhysicsObject {
    cpBody* _gripBody;
    cpConstraint* _gripJoint;
}

- (void)dealloc {
    [super dealloc];
    
}


- (void)onEnter {
    [super onEnter];
    
    // walk up the hierarchy until we find something that can provide the physics context
    
    id parent = self.parent;
    do {
        
        if ([parent conformsToProtocol:@protocol(CPPhysicsDelegate)])
            break;
        
        parent = self.parent;
        
    } while (parent != nil);
    
    if (parent == nil) {
        NSLog(@"%@ failed to find a parent that conforms to protocol CPPhysicsLayer!", [self class]);
    }
    
    self.physicsDelegate = parent;
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    
}

- (void)setCPBody:(cpBody *)CPBody {
    cpBodySetUserData(CPBody, self);
    [super setCPBody:CPBody];    
}

- (void) setDraggable:(BOOL)draggable {
    
    _draggable = draggable;
    
    if (_draggable) {
        
        if (_gripBody == NULL) {
        
            _gripBody = cpBodyNew(INFINITY, INFINITY);
            
            cpShape* mouseShape = cpCircleShapeNew(_gripBody, 1.0, cpvzero);
            cpShapeSetElasticity( mouseShape, 0.5f );
            cpShapeSetFriction( mouseShape, 0.5f );
            cpShapeSetSensor(mouseShape, cpTrue);
            
            cpSpaceAddShape(self.physicsDelegate.chipmunkSpace, mouseShape);
        }
    } else {
        cpBodyDestroy(_gripBody);
        cpSpaceRemoveConstraint([self.physicsDelegate chipmunkSpace], _gripJoint);
    }
    
}

- (void) objectDidCollideWithObject:(PhysicsObject *)otherObject collisionPhase:(CollisionPhase)phase arbiter:(cpArbiter *)collisionArbiter {
    // no-op; override
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (self.draggable == NO)
        return NO;
    
    CGPoint position = [[CCDirector sharedDirector] convertTouchToGL:touch];
    
    if (CGRectContainsPoint( [self boundingBox], position
                            )) {
        cpBodySetPos(_gripBody, position);
        cpBodySetVel(_gripBody, cpvzero);
        
        _gripJoint = cpPivotJointNew2(_gripBody, self.CPBody, cpvzero, cpBodyWorld2Local(self.CPBody, position));
        cpConstraintSetMaxForce(_gripJoint, 50000.0f);
        cpConstraintSetErrorBias(_gripJoint, cpfpow(1.0f - 0.15f, 60.0f));
        
        cpSpaceAddConstraint([self.physicsDelegate chipmunkSpace], _gripJoint);
        
        return YES;
    }
    
    return NO;
    
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (self.draggable == NO)
        return;
    
    cpSpaceRemoveConstraint([self.physicsDelegate chipmunkSpace], _gripJoint);
    cpConstraintDestroy(_gripJoint);
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (self.draggable == NO)
        return;

    CGPoint position = [[CCDirector sharedDirector] convertTouchToGL:touch];
    
    
    CGFloat framesPerSecond = 1.0 / [[CCDirector sharedDirector] secondsPerFrame];
    cpVect movementOffset = cpvsub(position, cpBodyGetPos(_gripBody));
    
    cpBodySetVel(_gripBody, cpvmult(movementOffset, framesPerSecond));
    cpBodySetPos(_gripBody, position);
    
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self ccTouchEnded:touch withEvent:event];
}



@end
