//
//  LevelLayer.h
//  Studyladder
//
//  Created by Jon Manning on 7/02/13.
//  Copyright 2013 Secret Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum  {
    PhysicsObjectCollisionBegan = 0,
    PhysicsObjectCollisionContinued, // not called for sensors
    PhysicsObjectCollisionEnded
} CollisionPhase;

@protocol CPPhysicsDelegate <NSObject>

@property (assign) cpSpace* chipmunkSpace;

- (void) updatePhysics:(ccTime)deltaTime;

- (CCNode*) childWithIdentifier:(NSString*)identifier;


@end

@interface PhysicsLayer : CCLayer <CPPhysicsDelegate> {
    
}

// override; must call super
- (void) initPhysics;

- (CCNode*) childWithIdentifier:(NSString*)identifier;

// Whether physics debugging should be visible. Defaults to NO.
@property (assign) BOOL showPhysicsDebugging;

@end
