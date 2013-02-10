//
//  LevelLayer.h
//  Studyladder
//
//  Created by Jon Manning on 7/02/13.
//  Copyright 2013 Secret Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol CPPhysicsDelegate <NSObject>

@property (assign) cpSpace* chipmunkSpace;

- (void) updatePhysics:(ccTime)deltaTime;

@end

@interface PhysicsLayer : CCLayer <CPPhysicsDelegate> {
    
}

@end
