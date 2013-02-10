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
    NSPointerArray* _bodiesToRemove;
    
}

@end

@implementation PhysicsLayer

void CallCollisionCallbacksForArbiter(cpArbiter *arb, CollisionPhase phase) {
    CP_ARBITER_GET_BODIES(arb, bodyA, bodyB);
    
    PhysicsObject* objectA = cpBodyGetUserData(bodyA);
    PhysicsObject* objectB = cpBodyGetUserData(bodyA);
    
    
    if (objectA != nil && objectB != nil) {
        [objectA objectDidCollideWithObject:objectB collisionPhase:phase arbiter:arb];
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
    cpSpaceStep(_chipmunkSpace, deltaTime);
    
    for (int i = 0; i < _bodiesToRemove.count; i++) {
        cpBody* body = [_bodiesToRemove pointerAtIndex:i];
        cpSpaceRemoveBody(self.chipmunkSpace, body);
    }
    
    [_bodiesToRemove setCount:0];
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
    
    [super dealloc];
    
}

- (void) initPhysics {
    CGSize s = [[CCDirector sharedDirector] winSize];

	//
	// rogue shapes
	// We have to free them manually
	//
	// bottom
	_walls[0] = cpSegmentShapeNew( self.chipmunkSpace->staticBody, cpv(0,0), cpv(s.width,0), 0.0f);
	
	// top
	_walls[1] = cpSegmentShapeNew( self.chipmunkSpace->staticBody, cpv(0,s.height), cpv(s.width,s.height), 0.0f);
	
	// left
	_walls[2] = cpSegmentShapeNew( self.chipmunkSpace->staticBody, cpv(0,0), cpv(0,s.height), 0.0f);
	
	// right
	_walls[3] = cpSegmentShapeNew( self.chipmunkSpace->staticBody, cpv(s.width,0), cpv(s.width,s.height), 0.0f);
	
	for( int i=0;i<4;i++) {
		cpShapeSetElasticity( _walls[i], 1.0f );
		cpShapeSetFriction( _walls[i], 1.0f );
		cpSpaceAddStaticShape(self.chipmunkSpace, _walls[i] );
	}
	
	_debugLayer = [CCPhysicsDebugNode debugNodeForCPSpace:self.chipmunkSpace];
    [self addChild:_debugLayer z:100];
	_debugLayer.visible = YES;
    
    cpSpaceSetDefaultCollisionHandler(self.chipmunkSpace, &CollisionBegin, NULL, &CollisionContinued, &CollisionEnd, NULL);
    
    _bodiesToRemove = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsOpaquePersonality];
	
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
        [_bodiesToRemove addPointer:physicsObject.chipmunkBody];
    }
    
    [super removeChild:child cleanup:cleanup];
        
}

@end
