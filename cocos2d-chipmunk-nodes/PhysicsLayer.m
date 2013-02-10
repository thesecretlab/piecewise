//
//  LevelLayer.m
//  Studyladder
//
//  Created by Jon Manning on 7/02/13.
//  Copyright 2013 Secret Lab. All rights reserved.
//

#import "PhysicsLayer.h"

@interface PhysicsLayer() {
    CCPhysicsDebugNode* _debugLayer;
    cpShape *_walls[4];
}

@end

@implementation PhysicsLayer

@synthesize chipmunkSpace = _chipmunkSpace;

- (cpSpace *)chipmunkSpace {
    if (_chipmunkSpace == NULL)
        _chipmunkSpace = cpSpaceNew();
    
    return _chipmunkSpace;
}

- (void)updatePhysics:(ccTime)deltaTime {
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
    [_debugLayer retain];
    [self addChild:_debugLayer z:100];
	_debugLayer.visible = YES;
	
}

- (void)update:(ccTime)delta {
    [self updatePhysics:delta];
}

- (void)onEnter {
    [super onEnter];
    
}

@end
