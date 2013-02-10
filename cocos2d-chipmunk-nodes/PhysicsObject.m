//
//  PhysicsObject.m
//  
//
//  Created by Jon Manning on 7/02/13.
//
//

#import "PhysicsObject.h"

@implementation PhysicsObject



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
}

@end
