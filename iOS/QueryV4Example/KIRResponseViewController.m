//
//  KIRResponseViewController.m
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

#import "KIRResponseViewController.h"
#import "KIRResultViewController.h"
#import "KIRJSONViewController.h"
#import "KIRWebViewController.h"
#import "KIRAppDelegate.h"


@interface KIRResponseViewController ()

// The main response object received from the Query API
@property (nonatomic, strong, readwrite) NSDictionary* response;

// The array of matching items
@property (nonatomic, strong, readwrite) NSArray* results;

// The raw response data received from the query API
@property (nonatomic, strong, readwrite) NSData* rawResponseData;

@end

@implementation KIRResponseViewController

enum {
	kResultsSectionIndex = 0,
	kDebugInformationSectionIndex,
	
	kNumSections
} ResultsViewSections;

@synthesize response;
@synthesize results;

- (id)initWithResponse:(NSDictionary*)responseDictionary rawJSONData:(NSData *)jsonData
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		self.response = responseDictionary;
		self.rawResponseData = jsonData;
		
		NSArray* resultsArray = [self.response objectForKey:@"results"];
		if ([resultsArray isKindOfClass:[NSArray class]]) {
			self.results = resultsArray;
		}
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.title = @"Results";
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return kNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	NSInteger rows = 0;
	
	switch (section) {
		case kResultsSectionIndex:
		{
			// Show one row for each item
			rows = self.results.count;
		}
			break;
			
		case kDebugInformationSectionIndex:
		{
			// Only one show the response JSON text
			rows = 1;
		}
	}
	
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}

	switch (indexPath.section) {
		case kResultsSectionIndex:
		{
			// We'll display the title of the item that matched along with the redirect_url, if present in the metadata.
			NSDictionary* result = [self.results objectAtIndex:indexPath.row];
			if ([result isKindOfClass:[NSDictionary class]]) {
				cell.textLabel.text = [result objectForKey:@"title"];
				cell.detailTextLabel.text = [[KIRAppDelegate redirectURLForResult:result] absoluteString];
				cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			} else {
				cell.textLabel.text = nil;
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
			break;
			
		case kDebugInformationSectionIndex:
			cell.textLabel.text = @"Raw JSON Response";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString* title = nil;
	
	switch (section) {
		case kResultsSectionIndex:
			title = [NSString stringWithFormat:@"%d %@", self.results.count, self.results.count == 1 ? @"Result" : @"Results"];
			break;
			
		case kDebugInformationSectionIndex:
			title = @"Debug Information";
			break;
	}
	
	return title;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case kResultsSectionIndex:
		{
			NSDictionary* result = [self.results objectAtIndex:indexPath.row];
			KIRResultViewController* resultViewController = [[KIRResultViewController alloc] initWithResult:result];
			[self.navigationController pushViewController:resultViewController animated:YES];
		}
			break;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case kResultsSectionIndex:
		{
			NSDictionary* result = [self.results objectAtIndex:indexPath.row];
			NSURL* url = [KIRAppDelegate redirectURLForResult:result];
			if (url != nil) {
				KIRWebViewController* webViewController = [[KIRWebViewController alloc] initWithURL:url];
				[self.navigationController pushViewController:webViewController animated:YES];
			}
		}
			break;
			
		case kDebugInformationSectionIndex:
		{
			KIRJSONViewController* jsonViewController = [[KIRJSONViewController alloc] initWithJSONData:self.rawResponseData];
			jsonViewController.title = @"JSON Response";
			[self.navigationController pushViewController:jsonViewController animated:YES];
		}
			break;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
