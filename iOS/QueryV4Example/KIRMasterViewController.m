//
//  KIRMasterViewController.m
//  Copyright (c) 2013 kooaba AG.
//
// All rights reserved. Redistribution and use in source and binary forms,
// with or without modification, are permitted provided that the following
// conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name of the kooaba AG nor the names of its contributors may be
//   used to endorse or promote products derived from this software without
//   specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "KIRMasterViewController.h"
#import "KIRAppDelegate.h"


@interface KIRMasterViewController (/* Private */)

// The MasterViewController is the only one that needs access to these two views.
@property (nonatomic, strong, readwrite) IBOutlet UIImageView* imageView;
@property (nonatomic, strong, readwrite) IBOutlet UITextView* textView;

@end

@implementation KIRMasterViewController

@synthesize imageView;
@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = NSLocalizedString(@"kooaba V4", nil);
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Add a Camera button 
	UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(chooseImage)];
	self.navigationItem.rightBarButtonItem = cameraButton;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

// Show the camera if the device has one, otherwise show the photo library to choose a picture.
- (void)chooseImage
{
	UIImagePickerController* pickerController = [[UIImagePickerController alloc] init];
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
	
	pickerController.delegate = self;
	[self presentModalViewController:pickerController animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];

	// Show the query image
	self.imageView.image = image;
	self.imageView.hidden = NO;
	self.textView.hidden = YES;

	KIRAppDelegate* appDelegate = (KIRAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	// Send the image to the kooaba V4 Query service with some JSON user data.
	NSString* jsonUserData = @"{\"user_id\":\"sample_code\"}";
	[appDelegate sendQueryImage:image withUserData:jsonUserData completion:^(NSString* result) {
		
		// This block is called when the query completes.
		// result will have either the JSON response from the kooaba server or an error string.
		// Hide the image in the UI and show the result.
		self.textView.text = result;
		self.textView.hidden = NO;
		self.imageView.hidden = YES;
	}];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
