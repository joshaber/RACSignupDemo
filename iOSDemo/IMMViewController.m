//
//  IMMViewController.m
//  iOSDemo
//
//  Created by Josh Abernathy on 9/24/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "IMMViewController.h"

// Our mission: create a form for the user to fill out. It should only allow
// submission if the form is valid. A form is valid if the user's entered a
// value for each field, and if the email and re-enter email fields match.
// 
// We want to minimize our statefulness for our own sanity. This means any
// non-essential state should be derived and driven entirely by the essential
// state.

@interface IMMViewController ()
// All user input is essential state. How else could we get it?
@property (nonatomic, weak) IBOutlet UITextField *firstNameField;
@property (nonatomic, weak) IBOutlet UITextField *lastNameField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *reEmailField;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIButton *createButton;

// `processing` and `error` are both essential even though they're not input by
// the user. They decide what state our form is in.
@property (nonatomic, assign) BOOL processing;
@property (nonatomic, strong) NSError *error;
@end

@implementation IMMViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	srand(time(NULL));

	// Are all entries valid? This is derived entirely from the values of our UI.
	RACSubscribable *formValid = [RACSubscribable
		combineLatest:@[
			self.firstNameField.rac_textSubscribable,
			self.lastNameField.rac_textSubscribable,
			self.emailField.rac_textSubscribable,
			self.reEmailField.rac_textSubscribable
		]
		reduce:^(RACTuple *xs) {
			NSString *firstName = xs[0];
			NSString *lastName = xs[1];
			NSString *email = xs[2];
			NSString *reEmail = xs[3];
			return @(firstName.length > 0 && lastName.length > 0 && email.length > 0 && reEmail.length > 0 && [email isEqual:reEmail]);
		}];

	// Get a subscribable from key-value observing the `processing` property.
	RACSubscribable *processing = RACAble(self.processing);

	// The button's enabledness is derived from whether we're processing and
	// whether our form is valid.
	RACSubscribable *buttonEnabled = [RACSubscribable combineLatest:@[ processing, formValid ] reduce:^(RACTuple *xs) {
		BOOL processing = [xs[0] boolValue];
		BOOL valid = [xs[1] boolValue];
		return @(!processing && valid);
	}];

	// The button's enabledness is driven by the `buttonEnabled` subscribable.
	RAC(self.createButton.enabled) = buttonEnabled;

	// The button's title color is driven by its enabledness.
	UIColor *defaultButtonTitleColor = self.createButton.titleLabel.textColor;
	RACSubscribable *buttonTextColor = [buttonEnabled select:^(NSNumber *x) {
		return x.boolValue ? defaultButtonTitleColor : [UIColor lightGrayColor];
	}];

	// Update the title color every our text color subscribable changes.
	[self.createButton rac_subscribeSelector:@selector(setTitleColor:forState:) withObjects:buttonTextColor, @(UIControlStateNormal)];

	// Our fields' text color and enabledness is derived from whether we're
	// processing.
	RACSubscribable *fieldTextColor = [processing select:^(NSNumber *x) {
		return x.boolValue ? [UIColor lightGrayColor] : [UIColor blackColor];
	}];

	RAC(self.firstNameField.textColor) = fieldTextColor;
	RAC(self.lastNameField.textColor) = fieldTextColor;
	RAC(self.emailField.textColor) = fieldTextColor;
	RAC(self.reEmailField.textColor) = fieldTextColor;

	RACSubscribable *notProcessing = [processing select:^(NSNumber *x) {
		return @(!x.boolValue);
	}];
	
	RAC(self.firstNameField.enabled) = notProcessing;
	RAC(self.lastNameField.enabled) = notProcessing;
	RAC(self.emailField.enabled) = notProcessing;
	RAC(self.reEmailField.enabled) = notProcessing;

	RACSubscribable *submit = [self.createButton rac_subscribableForControlEvents:UIControlEventTouchUpInside];
	// The first value from `processing` will be us setting it to NO below. So
	// skip that value and then let us know when processing ends.
	RACSubscribable *submissionEnded = [[processing
		skip:1]
		where:^ BOOL (NSNumber *x) {
			return !x.boolValue;
		}];
	// The submit count increments after the button's been clicked and we're
	// done processing.
	RACSubscribable *submitCount = [[RACSubscribable combineLatest:@[ submit, submissionEnded ]] scanWithStart:@0 combine:^(NSNumber *running, id _) {
		return @(running.integerValue + 1);
	}];

	// The status label only shows up after the first completed submission.
	RAC(self.statusLabel.hidden) = [submitCount select:^(NSNumber *x) {
		return @(x.integerValue < 1);
	}];

	RACSubscribable *error = RACAble(self.error);

	// Status label text and color are driven by whether we got an error.
	RAC(self.statusLabel.text) = [error select:^(id x) {
		return x != nil ? NSLocalizedString(@"An error occurred!", @"") : NSLocalizedString(@"You're good!", @"");
	}];
	RAC(self.statusLabel.textColor) = [error select:^(id x) {
		return x != nil ? [UIColor redColor] : [UIColor greenColor];
	}];

	RAC(UIApplication.sharedApplication, networkActivityIndicatorVisible) = processing;

	self.error = nil;
	self.processing = NO;

	__weak id weakSelf = self;
	[submit subscribeNext:^(id _) {
		IMMViewController *strongSelf = weakSelf;
		strongSelf.processing = YES;
		
		[[[strongSelf doSomeNetworkStuff] finally:^{
			strongSelf.processing = NO;
		}] subscribeNext:^(id x) {
			strongSelf.error = nil;
		} error:^(NSError *error) {
			strongSelf.error = error;
		}];
	}];
}

- (RACSubscribable *)doSomeNetworkStuff {
	return [[[RACSubscribable interval:3.0f] take:1] selectMany:^(id _) {
		BOOL success = rand() % 2;
		return success ? [RACSubscribable return:[RACUnit defaultUnit]] : [RACSubscribable error:[NSError errorWithDomain:@"" code:0 userInfo:nil]];
	}];
}

@end
