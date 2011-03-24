//
//  TestRigAppDelegate.h
//  TestRig
//
//  Created by Benjamin Blundell on 23/03/2011.
//  Copyright 2011 Section9. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TestRigAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
