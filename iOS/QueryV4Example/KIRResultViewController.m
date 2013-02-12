//
//  KIRResultViewController.m
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

#import "KIRResultViewController.h"
#import "KIRJSONViewController.h"


@interface KIRResultViewController ()

@property (nonatomic, strong, readwrite) NSDictionary* result;
@property (nonatomic, strong, readwrite) NSArray* sortedKeys;

@end

@implementation KIRResultViewController

@synthesize result;
@synthesize sortedKeys;

- (id)initWithResult:(NSDictionary*)aResult
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		self.result = aResult;
		
		// Sort the attributes of the result so that they are displayed in the same order each time.
		self.sortedKeys = [[self.result allKeys] sortedArrayUsingSelector:@selector(compare:)];
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	// The title of this screen is the title of the item
	self.navigationItem.title = [self.result objectForKey:@"title"];
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
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return self.sortedKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
	}

	cell.textLabel.text = nil;
	cell.detailTextLabel.text = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	NSString* key = [self.sortedKeys objectAtIndex:indexPath.row];
	cell.textLabel.text = key;
	
	id value = [self.result objectForKey:key];
	if ([key isEqualToString:@"metadata"]) {
		if ([NSJSONSerialization isValidJSONObject:value]) {
			// The metadata is an array or object, indicate that we can show more detail in a separate view
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else {
			// The metadata is a simple value (string, number, boolean, etc.), just display the value
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", value];
		}
	} else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
		// The value for this key is a string or number, just display the value
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", value];
	} else if ([value isKindOfClass:[NSArray class]]) {
		cell.detailTextLabel.text = @"[array]";
	} else if ([value isKindOfClass:[NSDictionary class]]) {
		cell.detailTextLabel.text = @"{object}";
	}
	
	return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath* selectedIndexPath = nil;
	
	NSString* key = [self.sortedKeys objectAtIndex:indexPath.row];
	if ([key isEqualToString:@"metadata"]) {
		id metadata = [self.result objectForKey:key];
		// If the metadata is an array or object, then this row can be selected.
		if ([NSJSONSerialization isValidJSONObject:metadata]) {
			selectedIndexPath = indexPath;
		}
	}
	
	return selectedIndexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* key = [self.sortedKeys objectAtIndex:indexPath.row];
	if ([key isEqualToString:@"metadata"]) {
		id metadata = [self.result objectForKey:key];
		// If the metadata is an array or object, then show the serialized metadata. Otherwise, it was displayed as the value.
		if ([NSJSONSerialization isValidJSONObject:metadata]) {
			NSData* jsonData = [NSJSONSerialization dataWithJSONObject:metadata options:0 error:nil];
			KIRJSONViewController* jsonViewController = [[KIRJSONViewController alloc] initWithJSONData:jsonData];
			jsonViewController.title = @"Metadata";
			[self.navigationController pushViewController:jsonViewController animated:YES];
		}
	}
}

@end
