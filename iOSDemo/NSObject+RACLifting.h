//
//  NSObject+RACLifting.h
//  iOSDemo
//
//  Created by Josh Abernathy on 10/13/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (RACLifting)

// Lifts the selector on self into the reactive world. The selector will be
// called whenever any subscribable argument sends a value, but only after each
// subscribable has sent a value.
//
// Returns a subscribable which sends the return value from each invocation of
// the selector. If the selector returns void, it instead sends the receiver. It
// completes only after all the subscribable arguments complete.
- (RACSubscribable *)rac_lift:(SEL)selector withObjects:(id)arg, ...;

@end
