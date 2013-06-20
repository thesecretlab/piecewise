//
//  LevelLayer.m
//  Studyladder
//
//  Created by Jon Manning on 7/02/13.
//  Copyright 2013 Secret Lab. All rights reserved.
//

#import "PhysicsLayer.h"
#import "PhysicsObject.h"


@interface PhysicsLayer() {
    CCPhysicsDebugNode* _debugLayer;
    cpShape *_walls[4];
    
}

@end

@implementation PhysicsLayer

@dynamic showPhysicsDebugging;


void RemoveBodyOnPostStep(cpSpace *space, void *key, void *data) {
    
    PhysicsObject* object = CFBridgingRelease(key);
    
    [object objectWasRemovedFromSpace];
    
}


void CallCollisionCallbacksForArbiter(cpArbiter *arb, CollisionPhase phase) {
    CP_ARBITER_GET_BODIES(arb, bodyA, bodyB);
    
    PhysicsObject* objectA = (__bridge PhysicsObject *)(cpBodyGetUserData(bodyA));
    PhysicsObject* objectB = (__bridge PhysicsObject *)(cpBodyGetUserData(bodyB));
    
    if ([objectA shouldCollideWithBody:bodyB]) {
        [objectA objectDidCollideWithObject:objectB collisionPhase:phase arbiter:arb];
    }
    if ([objectB shouldCollideWithBody:bodyA]) {
        [objectB objectDidCollideWithObject:objectA collisionPhase:phase arbiter:arb];
    }
    
    
}

cpBool CollisionBegin (cpArbiter *arb, cpSpace *space, void *data) {
    CallCollisionCallbacksForArbiter(arb, PhysicsObjectCollisionBegan);
    return cpTrue;
};

void CollisionContinued (cpArbiter *arb, cpSpace *space, void *data) {
    CallCollisionCallbacksForArbiter(arb, PhysicsObjectCollisionContinued);
}

void CollisionEnd (cpArbiter *arb, cpSpace *space, void *data) {
    CallCollisionCallbacksForArbiter(arb, PhysicsObjectCollisionEnded);
};

@synthesize chipmunkSpace = _chipmunkSpace;

- (cpSpace *)chipmunkSpace {
    if (_chipmunkSpace == NULL)
        _chipmunkSpace = cpSpaceNew();
    
    return _chipmunkSpace;
}

- (void)updatePhysics:(ccTime)deltaTime {
    
    cpSpaceEachBody_b(_chipmunkSpace, ^(cpBody *body) {
        PhysicsObject* object = (__bridge PhysicsObject *)(cpBodyGetUserData(body));
        if ([object isKindOfClass:[PhysicsObject class]]) {
            [object objectWillUpdatePhysics:deltaTime];
        }
    });
    
    cpSpaceStep(_chipmunkSpace, deltaTime);
    
    
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self initPhysics];
        
        [self scheduleUpdate];
    }
    
    return self;
}

- (void)dealloc {
    for (int i = 0; i < 4; i++) {
        cpShapeDestroy(_walls[i]);
    }
    
    cpSpaceDestroy(self.chipmunkSpace);
    
    
}

- (void) initPhysics {
    CGSize s = self.contentSize;
    
    const float wallThickness = 40.0f;

	//
	// rogue shapes
	// We have to free them manually
	//
	// bottom
	_walls[0] = cpSegmentShapeNew( self.chipmunkSpace->staticBody, cpv(0,0), cpv(s.width,0), wallThickness);
	
	// top
	_walls[1] = cpSegmentShapeNew( self.chipmunkSpace->staticBody, cpv(0,s.height), cpv(s.width,s.height), wallThickness);
	
	// left
	_walls[2] = cpSegmentShapeNew( self.chipmunkSpace->staticBody, cpv(0,0), cpv(0,s.height), wallThickness);
	
	// right
	_walls[3] = cpSegmentShapeNew( self.chipmunkSpace->staticBody, cpv(s.width,0), cpv(s.width,s.height), wallThickness);
	
	for( int i=0;i<4;i++) {
		cpShapeSetElasticity( _walls[i], 1.0f );
		cpShapeSetFriction( _walls[i], 1.0f );
		cpSpaceAddStaticShape(self.chipmunkSpace, _walls[i] );
	}
	
	_debugLayer = [CCPhysicsDebugNode debugNodeForCPSpace:self.chipmunkSpace];
    [self addChild:_debugLayer z:100];

	_debugLayer.visible = YES;
    
    cpSpaceSetDefaultCollisionHandler(self.chipmunkSpace, &CollisionBegin, NULL, &CollisionContinued, &CollisionEnd, NULL);
    
    [self setShowPhysicsDebugging:NO];
	
}

- (void)setShowPhysicsDebugging:(BOOL)showPhysicsDebugging {
    _debugLayer.visible = showPhysicsDebugging;
}

- (BOOL)showPhysicsDebugging {
    return _debugLayer.visible;
}

- (void)update:(ccTime)delta {
    [self updatePhysics:delta];
}

- (void)onEnter {
    [super onEnter];    
}

- (void)removeChild:(CCNode *)child cleanup:(BOOL)cleanup {
    if ([child isKindOfClass:[PhysicsObject class]]) {
        
        PhysicsObject* physicsObject = (PhysicsObject*)child;
        
        if (physicsObject.CPBody != NULL) {
            
            if (cpSpaceIsLocked(_chipmunkSpace)) {
                cpSpaceAddPostStepCallback(_chipmunkSpace, &RemoveBodyOnPostStep, (__bridge void *)(physicsObject), NULL);
            } else {
                cpSpaceRemoveBody(_chipmunkSpace, physicsObject.CPBody);
            }
        }
        
    }
    
    [super removeChild:child cleanup:cleanup];
        
}

- (CCNode*) searchChild:(CCNode*)node forIdentifier:(NSString*)identifier {
    
    if ([node respondsToSelector:@selector(identifier)]) {
        if ([[(id)node identifier] isEqualToString:identifier])
            return node;
    }
    
    for (CCNode* child in node.children) {
        CCNode* result = [self searchChild:child forIdentifier:identifier];
        if (result != nil)
            return result;
    }
    
    return nil;
    
}

- (CCNode*) searchChild:(CCNode*)node forTag:(NSUInteger)tag {
    
    if ([node respondsToSelector:@selector(identifier)]) {
        if ([node tag] == tag)
            return node;
    }
    
    for (CCNode* child in node.children) {
        CCNode* result = [self searchChild:child forTag:tag];
        if (result != nil)
            return result;
    }
    
    return nil;
    
}


- (CCNode*) childWithTag:(NSUInteger)tag {
    return [self searchChild:self forTag:tag];
}

- (CCNode*) childWithIdentifier:(NSString*)identifier {
    return [self searchChild:self forIdentifier:identifier];
}

@end
