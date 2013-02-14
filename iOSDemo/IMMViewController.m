//
//  IMMViewController.m
//  iOSDemo
//
//  Created by Josh Abernathy on 9/24/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "IMMViewController.h"
#import "EXTScope.h"

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

@end

@implementation IMMViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	// Are all entries valid? This is derived entirely from the values of our UI.
	RACSignal *formValid = [RACSignal
		combineLatest:@[
			self.firstNameField.rac_textSignal,
			self.lastNameField.rac_textSignal,
			self.emailField.rac_textSignal,
			self.reEmailField.rac_textSignal
		]
		reduce:^(NSString *firstName, NSString *lastName, NSString *email, NSString *reEmail) {
			return @(firstName.length > 0 && lastName.length > 0 && email.length > 0 && reEmail.length > 0 && [email isEqual:reEmail]);
		}];

	// Use a command to encapsulate the validity and in-flight check.
	RACCommand *doNetworkStuff = [RACCommand commandWithCanExecuteSignal:formValid];
	RACSignal *networkResults = [[[doNetworkStuff
		addSignalBlock:^(id _) {
			// Wait 3 seconds and then send a random YES/NO.
			return [[[RACSignal interval:3] take:1] sequenceMany:^{
				BOOL success = arc4random() % 2;
				return [RACSignal return:@(success)];
			}];
		}]
		// -addSignalBlock: returns a signal of signals. We only care about the
		// latest (most recent).
		switchToLatest]
		deliverOn:RACScheduler.mainThreadScheduler];

	RACSignal *submit = [self.createButton rac_signalForControlEvents:UIControlEventTouchUpInside];
	[submit subscribeNext:^(id sender) {
		[doNetworkStuff execute:sender];
	}];

	// Create a signal by KVOing the command's canExecute property. The signal
	// starts with the current value of canExecute.
	RACSignal *buttonEnabled = RACAbleWithStart(doNetworkStuff, canExecute);

	// The button's enabledness is driven by whether the command can execute,
	// which means that the form is valid and the command isn't already
	// executing.
	RAC(self.createButton.enabled) = buttonEnabled;

	// The button's title color is driven by its enabledness.
	UIColor *defaultButtonTitleColor = self.createButton.titleLabel.textColor;
	RACSignal *buttonTextColor = [buttonEnabled map:^(NSNumber *x) {
		return x.boolValue ? defaultButtonTitleColor : UIColor.lightGrayColor;
	}];

	// Update the title color every our text color signal changes. We can't use
	// the RAC macro since the only way to change the title color is by calling
	// a multi-argument method. So we lift the selector into the RAC world
	// instead.
	[self.createButton rac_liftSelector:@selector(setTitleColor:forState:) withObjects:buttonTextColor, @(UIControlStateNormal)];

	// Our fields' text color and enabledness is derived from whether our
	// command is executing.
	RACSignal *executing = [RACAble(doNetworkStuff, executing) deliverOn:RACScheduler.mainThreadScheduler];
	RACSignal *fieldTextColor = [executing map:^(NSNumber *x) {
		return x.boolValue ? UIColor.lightGrayColor : UIColor.blackColor;
	}];

	RAC(self.firstNameField.textColor) = fieldTextColor;
	RAC(self.lastNameField.textColor) = fieldTextColor;
	RAC(self.emailField.textColor) = fieldTextColor;
	RAC(self.reEmailField.textColor) = fieldTextColor;

	RACSignal *notProcessing = [executing map:^(NSNumber *x) {
		return @(!x.boolValue);
	}];
	RAC(self.firstNameField.enabled) = notProcessing;
	RAC(self.lastNameField.enabled) = notProcessing;
	RAC(self.emailField.enabled) = notProcessing;
	RAC(self.reEmailField.enabled) = notProcessing;

	// Submission ends when the user clicks the button and then executing stops.
	RACSignal *submissionEnded = [[[submit mapReplace:executing] switchToLatest] filter:^ BOOL (NSNumber *processing) {
		return !processing.boolValue;
	}];

	// The submit count increments after submission has ended.
	RACSignal *submitCount = [submissionEnded scanWithStart:@0 combine:^(NSNumber *running, id _) {
		return @(running.integerValue + 1);
	}];

	// Status label is hidden until after we've had a submission complete.
	RAC(self.statusLabel.hidden) = [[submitCount startWith:@0] map:^(NSNumber *x) {
		return @(x.integerValue < 1);
	}];

	// Derive the status label's text and color from our network result.
	RAC(self.statusLabel.text) = [networkResults map:^(NSNumber *x) {
		return x.boolValue ? NSLocalizedString(@"You're good!", @"") : NSLocalizedString(@"An error occurred!", @"");
	}];
	RAC(self.statusLabel.textColor) = [networkResults map:^(NSNumber *x) {
		return x.boolValue ?  UIColor.greenColor : UIColor.redColor;
	}];

	// Keep the activity indicator up-to-date with our execution status.
	RAC(UIApplication.sharedApplication, networkActivityIndicatorVisible) = executing;
}

@end
