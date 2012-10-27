//
//  IMMSimpleTest.m
//  iOSDemo
//
//  Created by Josh Abernathy on 9/25/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "IMMSimpleTest.h"

@implementation IMMSimpleTest

+ (void)doStuff {
//	RACSubscribable *subscribable = [RACSubscribable createSubscribable:^RACDisposable *(id<RACSubscriber> subscriber) {
//		[subscriber sendNext:@1];
//		[subscriber sendNext:@2];
//		[subscriber sendCompleted];
//		return nil;
//	}];
//
//	[subscribable subscribeNext:^(id x) {
//		NSLog(@"Got %@", x);
//	} completed:^{
//		NSLog(@"Completed!");
//	}];

	////////////////////////////////////////////////////////////////////////////////////////////////////////

//	RACSubscribable *subscribable = [RACSubscribable createSubscribable:^RACDisposable *(id<RACSubscriber> subscriber) {
////		NSLog(@"subscribed!");
////		DoExpensiveThing();
//
//		NSError *error = nil;
//		BOOL sucess = DoNetworkOperation(&error);
//		[subscriber sendError:error];
////		[subscriber sendNext:@1];
////		[subscriber sendNext:@2];
//		[subscriber sendCompleted];
//		return nil;
//	}];
//
//	[subscribable subscribeNext:^(id x) {
//		NSLog(@"Got %@", x);
//	} completed:^{
//		NSLog(@"Completed!");
//	}];
//
//	[subscribable subscribeNext:^(id x) {
//		NSLog(@"Got %@", x);
//	} completed:^{
//		NSLog(@"Completed!");
//	}];

	////////////////////////////////////////////////////////////////////////////////////////////////////////
	
//	RACSubscribable *subscribable = [RACSubscribable createSubscribable:^RACDisposable *(id<RACSubscriber> subscriber) {
//		[subscriber sendNext:@1];
//		[subscriber sendNext:@2];
//		[subscriber sendNext:@3];
//		[subscriber sendNext:@4];
//		[subscriber sendNext:@5];
//		[subscriber sendNext:@6];
//		[subscriber sendNext:@7];
//		[subscriber sendCompleted];
//		return nil;
//	}];

//	[[subscribable where:^BOOL(NSNumber *x) {
//		return x.unsignedIntegerValue % 2 != 0;
//	}] subscribeNext:^(id x) {
//		NSLog(@"Got %@", x);
//	} completed:^{
//		NSLog(@"Completed!");
//	}];

//	[[subscribable select:^(NSNumber *x) {
//		return [NSString stringWithFormat:@"Hey I multiplied by 100! %lu", (unsigned long) (x.unsignedIntegerValue * 100)];
//	}] subscribeNext:^(id x) {
//		NSLog(@"Got %@", x);
//	} completed:^{
//		NSLog(@"Completed!");
//	}];

	////////////////////////////////////////////////////////////////////////////////////////////////////////

//	RACSubscribable *subscribable = [RACSubscribable generatorWithStart:@1 next:^(NSNumber *x) {
//		return @(x.unsignedIntegerValue + 1);
//	}];

//	[subscribable subscribeNext:^(id x) {
//		NSLog(@"Got %@", x);
//	} completed:^{
//		NSLog(@"Completed!");
//	}];

//	[[subscribable take:100] subscribeNext:^(id x) {
//		NSLog(@"Got %@", x);
//	} completed:^{
//		NSLog(@"Completed!");
//	}];

//	[[[subscribable where:^BOOL(NSNumber *x) {
//		return x.unsignedIntegerValue % 7 == 0;
//	}] take:100] subscribeNext:^(id x) {
//		NSLog(@"Got %@", x);
//	} completed:^{
//		NSLog(@"Completed!");
//	}];
}

@end
