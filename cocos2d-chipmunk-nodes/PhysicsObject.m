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

@synthesize identifier = identifier;

- (void)onEnter {
    [super onEnter];
    
    // walk up the hierarchy until we find something that can provide the physics context
    
    id parent = self.parent;
    do {
        
        if ([parent conformsToProtocol:@protocol(CPPhysicsDelegate)])
            break;
        
        parent = [parent parent];
        
    } while (parent != nil);
    
    if (parent == nil) {
        NSLog(@"%@ failed to find a parent that conforms to protocol CPPhysicsLayer!", [self class]);
    }
    
    self.touchEnabled = YES;
    
    self.physicsDelegate = parent;
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    
}

- (void)onExit {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

- (void)setCPBody:(cpBody *)CPBody {
    if (CPBody != NULL) {
        cpBodySetUserData(CPBody, (void*)CFBridgingRetain(self));
        self.rotation = CC_RADIANS_TO_DEGREES(cpBodyGetAngle(CPBody));
        self.position = cpBodyGetPos(CPBody);
    }
    [super setCPBody:CPBody];
}

- (void) setDraggable:(BOOL)draggable {
    
    _draggable = draggable;
    
    cpSpace* space = [self.physicsDelegate chipmunkSpace];
    
    if (space == NULL) {
        _draggable = NO;
        return;
    }
    
    if (_draggable) {
        
        if (_gripBody == NULL) {
        
            _gripBody = cpBodyNew(INFINITY, INFINITY);
            
            cpShape* mouseShape = cpCircleShapeNew(_gripBody, 1.0, cpvzero);
            cpShapeSetElasticity( mouseShape, 0.5f );
            cpShapeSetFriction( mouseShape, 0.5f );
            cpShapeSetSensor(mouseShape, cpTrue);
            
            cpSpaceAddShape(space, mouseShape);
        }
    } else {
        
        if (_gripBody) {
            if (cpSpaceContainsBody(space, _gripBody));
            
            cpBodyEachShape_b(self.CPBody, ^(cpShape *shape) {
                cpSpaceRemoveShape(space, shape);
                cpShapeFree(shape);
            });
            
            if (_gripJoint != NULL)
                cpSpaceRemoveConstraint(space, _gripJoint);
            
            cpBodyDestroy(_gripBody);
            _gripBody = NULL;
        }
    }
    
}

- (void) objectDidCollideWithObject:(PhysicsObject *)otherObject collisionPhase:(CollisionPhase)phase arbiter:(cpArbiter *)collisionArbiter {
    // no-op; override
    
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (self.draggable == NO)
        return NO;
    
    if (self.CPBody == nil)
        return NO;
    
    if (_gripJoint != NULL)
        return NO;
    
    if (_touchEnabled == NO)
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
        
        self.dragging = YES;
        
        return YES;
    }
    
    return NO;
    
    
}

- (void) stopPhysics {
    
    cpBody* body = self.CPBody;
    
    if (self.CPBody == nil)
        return;
    
    CGPoint position = cpBodyGetPos(body);
    CGFloat rotation = self.rotation;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        cpBodyEachShape_b(body, ^(cpShape *shape) {
            cpSpaceRemoveShape(cpBodyGetSpace(body), shape);
            cpShapeFree(shape);
        });
        
        cpSpaceRemoveBody(cpBodyGetSpace(body), body);
    }];
    
    self.CPBody = nil;
    self.rotation = rotation;
    self.position = position;
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (self.draggable == NO)
        return;
    
    [self stopDragging];
}

- (void) stopDragging {
    if (_gripJoint != NULL) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (_gripJoint != NULL) {
                cpSpaceRemoveConstraint([self.physicsDelegate chipmunkSpace], _gripJoint);
                cpConstraintFree(_gripJoint);
                self.dragging = NO;
                _gripJoint = NULL;
            }
        }];
    }
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (self.draggable == NO)
        return;

    CGPoint position = [[CCDirector sharedDirector] convertTouchToGL:touch];
    
    
    cpVect movementOffset = cpvsub(position, cpBodyGetPos(_gripBody));
    
    cpBodySetVel(_gripBody, cpvmult(movementOffset, [[CCDirector sharedDirector] secondsPerFrame]));
    cpBodySetPos(_gripBody, position);
    
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self ccTouchEnded:touch withEvent:event];
}

- (void)objectWasRemovedFromSpace {
    if (self.CPBody) {
        
        // We need to remove all shapes assocated with this body before the body can be removed
        cpSpace* space = cpBodyGetSpace(self.CPBody);
        cpBodyEachShape_b(self.CPBody, ^(cpShape *shape) {
            cpSpaceRemoveShape(space, shape);
            cpShapeFree(shape);
        });
        
        // Tidy up the grip body and joint
        self.draggable = NO;
        
        // Now free the body
        cpSpaceRemoveBody(space, self.CPBody);
        cpBodyFree(self.CPBody);
        
        
        
    }
}

- (void)objectWillUpdatePhysics:(ccTime)deltaTime {
    if (self.dragBreakForce > 0) {
        if (_gripJoint) {
            cpFloat force = cpConstraintGetImpulse(_gripJoint)/deltaTime;
            // If the force is almost as big as the joint's max force, break the joint.
            if(force > 0.9*self.dragBreakForce){
                [self stopDragging];
            }

        }
    }
    // no-op; designed to be overridden
}


- (BOOL) shouldCollideWithBody:(cpBody*)body {
    if (body == _gripBody)
        return NO;
    
    return YES;
}


@end
