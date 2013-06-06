//
//  Obstacle.m
//  Studyladder
//
//  Created by Jon Manning on 7/02/13.
//  Copyright 2013 Secret Lab. All rights reserved.
//

#import "Obstacle.h"

#import "PhysicsLayer.h"

@implementation Obstacle {
    cpShape* shape;
}

-(id) init {
    self = [super init];
    
    
    if (self) {
        
    }
    
    return self;
}

- (void) deactivate {
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (shape == NULL)
            return;
        
        cpSpaceRemoveShape([self.physicsDelegate chipmunkSpace], shape);
        shape = NULL;
        self.CPBody = NULL;
    }];
    
    CCSequence* action = [CCSequence actions:[CCFadeTo actionWithDuration:0.25 opacity:0.0], [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParent];
    }], nil];
    
    [self runAction:action];
    
    
}

- (void) onEnter {
    [super onEnter];
    
    cpSpace* space = [self.physicsDelegate chipmunkSpace];
    
    cpBody *body = cpBodyNewStatic();
    cpBodySetPos( body, self.position );
    cpBodySetAngle(body, CC_DEGREES_TO_RADIANS(-self.rotation) );
    
    shape = cpBoxShapeNew(body, self.contentSize.width * self.scaleX, self.contentSize.height * self.scaleY);
    cpShapeSetElasticity( shape, 0.5f );
    cpShapeSetFriction( shape, 0.5f );
    cpSpaceAddShape(space, shape);
}

@end
