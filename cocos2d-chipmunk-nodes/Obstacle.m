//
//  Obstacle.m
//  Studyladder
//
//  Created by Jon Manning on 7/02/13.
//  Copyright 2013 Secret Lab. All rights reserved.
//

#import "Obstacle.h"

#import "PhysicsLayer.h"

@implementation Obstacle

-(id) init {
    self = [super init];
    
    
    if (self) {
        
    }
    
    return self;
}

- (void) onEnter {
    [super onEnter];
    
    cpSpace* space = [self.physicsDelegate chipmunkSpace];
    
    cpBody *body = cpBodyNewStatic();
    cpBodySetPos( body, self.position );
    cpBodySetAngle(body, CC_DEGREES_TO_RADIANS(-self.rotation) );
    
    cpShape* shape = cpBoxShapeNew(body, self.contentSize.width * self.scaleX, self.contentSize.height * self.scaleY);
    cpShapeSetElasticity( shape, 0.5f );
    cpShapeSetFriction( shape, 0.5f );
    cpSpaceAddShape(space, shape);
}

@end
