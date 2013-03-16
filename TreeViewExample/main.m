//
//  main.m
//  TreeViewExample
//
//  Created by kernel on 13/03/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAAppDelegate.h"

int main(int argc, char *argv[]) {
	@autoreleasepool {
#ifdef DEBUG
		@try {
			return UIApplicationMain(argc, argv, nil, NSStringFromClass([DAAppDelegate class]));
		}
		@catch (NSException *exception) {
			NSLog(@"EXC Cattcha globally in main.m. Exc: %@", exception);
			NSLog(@"Call Stack: %@", [exception callStackSymbols]);
		}
		@finally {
			NSLog(@"See main.m for details.");
		}
#else
		return UIApplicationMain(argc, argv, nil, NSStringFromClass([SPAppDelegate class]));
#endif
	}
}
