//
//  KIRQueryRequest.m
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

#import "KIRQueryRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "Base64.h"


@interface KIRQueryRequest (/* Private */)

@property (nonatomic, strong, readwrite) NSURL* queryURL;
@property (nonatomic, strong, readwrite) NSData* imageData;
@property (nonatomic, strong, readwrite) NSString* imageContentType;
@property (nonatomic, strong, readwrite) NSMutableData* bodyData;
@property (nonatomic, strong, readwrite) NSString* boundary;

@end


@implementation KIRQueryRequest

@synthesize userData;
@synthesize queryURL;
@synthesize imageData;
@synthesize bodyData;
@synthesize boundary;

- (id)initWithURL:(NSURL*)requestURL imageData:(NSData*)data imageContentType:(NSString*)contentType
{
	self = [super init];
	if (self != nil)
	{
		self.queryURL = requestURL;
		self.imageData = data;
		self.imageContentType = contentType;
		self.bodyData = [NSMutableData data];
		
		// Create a unique boundary string for this request
		CFUUIDRef uuidRef = CFUUIDCreate(NULL);
		CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
		self.boundary = (__bridge NSString*)uuidStringRef;
		CFRelease(uuidStringRef);
		CFRelease(uuidRef);
	}
	
	return self;
}

- (NSDateFormatter*)httpDateFormatter
{
	static NSDateFormatter* formatter = nil;
	
	if (formatter == nil)
	{
		NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		formatter = [[NSDateFormatter alloc] init];
		formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
		formatter.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
		
		// Always set the US locale because on non-US devices the date string could be formatted incorrectly
		formatter.locale = usLocale;
	}
	
	return formatter;
}

- (NSString*)md5DigestForData:(NSData*)data
{
	uint8_t md5result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([data bytes], [data length], md5result);
	NSMutableString *hexDigest = [NSMutableString string];
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
	{
		[hexDigest appendFormat:@"%02x", md5result[i]];
	}
	
	return hexDigest;
}

- (NSData*)sha1DigestForString:(NSString*)string withSecretKey:(NSString*)secretKey
{
	NSData* inputData = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSData* keyData = [secretKey dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char hmacSha1Bytes[CC_SHA1_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA1, keyData.bytes, keyData.length, inputData.bytes, inputData.length, hmacSha1Bytes);
	NSData *sha1RawDigest = [NSData dataWithBytes:hmacSha1Bytes length:CC_SHA1_DIGEST_LENGTH];
	return sha1RawDigest;
}

- (void)appendTextString:(NSString *)text forKey:(NSString *)key
{
	NSMutableString* textString = [NSMutableString string];
	[textString appendFormat:@"--%@\r\n", self.boundary];
	[textString appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key];
	[textString appendString:@"Content-Type: text/plain; charset=utf-8\r\n"];
	[textString	appendFormat:@"\r\n%@\r\n", text];
	[self.bodyData appendData:[textString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendJSONData:(NSData*)jsonData forKey:(NSString*)key
{
	if (jsonData != nil)
	{
		NSMutableString* textString = [NSMutableString string];
		[textString appendFormat:@"--%@\r\n", self.boundary];
		[textString appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key];
		[textString appendString:@"Content-Type: application/json; charset=utf-8\r\n"];
		[textString	appendFormat:@"\r\n"];
		[self.bodyData appendData:[textString dataUsingEncoding:NSUTF8StringEncoding]];
		[self.bodyData appendData:jsonData];
		[self.bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}
}

- (void)appendFileData:(NSData*)fileData forKey:(NSString*)key contentType:(NSString*)contentType name:(NSString*)name filename:(NSString*)filename
{
	NSMutableString* textString = [NSMutableString string];
	[textString appendFormat:@"--%@\r\n", self.boundary];
	[textString appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename];
	[textString appendFormat:@"Content-Type: %@\r\n", contentType];
	[textString appendString:@"Content-Transfer-Encoding: binary\r\n"];
	[textString appendString:@"\r\n"];
	[self.bodyData appendData:[textString dataUsingEncoding:NSUTF8StringEncoding]];
	[self.bodyData appendData:fileData];
	[self.bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSURLRequest*)signedRequestWithKeyID:(NSString*)keyID secretToken:(NSString*)secretToken
{
	// Appends the user_data (JSON) to the request body
	if (self.userData != nil)
	{
		[self appendJSONData:self.userData forKey:@"user_data"];
	}
	
	// Add the query image
	[self appendFileData:self.imageData forKey:@"image" contentType:self.imageContentType name:@"image" filename:@"query.jpeg"];
	
	// Add a closing boundary
	NSString* closingBoundary = [NSString stringWithFormat:@"--%@--\r\n", self.boundary];
	[self.bodyData appendData:[closingBoundary dataUsingEncoding:NSUTF8StringEncoding]];

	// Calculate the query signature. The signature consists of the following parts separated by a newline "\n"
	// - HTTP method ("POST")
	// - MD5 of the request content
	// - The content type ("multipart/form-data")
	// - The date (current date and time)
	// - The request path (usually "/v4/query")
	NSString* httpMethod = @"POST";
	NSString* urlPath = [self.queryURL path];
	NSString* contentType = @"multipart/form-data";
	NSString* contentMD5 = [self md5DigestForData:self.bodyData];
	NSString* dateValue = [self.httpDateFormatter stringFromDate:[NSDate date]];
	NSString* stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@", httpMethod, contentMD5, contentType, dateValue, urlPath];
	NSData* signatureData = [self sha1DigestForString:stringToSign withSecretKey:secretToken];
	NSString* signature = [signatureData base64EncodedString];
	
	// Create the Authorization header value, which is equal to "KA <key-id>:<signature>"
	NSString* authorizationValue = [NSString stringWithFormat:@"KA %@:%@", keyID, signature];
	
	// Set the content type and specify the boundary used for multipart/form-data
	NSString* contentTypeValue = [NSString stringWithFormat:@"%@; boundary=%@", contentType, self.boundary];

	// Put it all together to create a signed request
	NSMutableURLRequest* signedRequest = [NSMutableURLRequest requestWithURL:self.queryURL];
	[signedRequest setHTTPMethod:httpMethod];
	[signedRequest setHTTPBody:self.bodyData];
	[signedRequest setValue:contentTypeValue forHTTPHeaderField:@"Content-Type"];
	[signedRequest addValue:authorizationValue forHTTPHeaderField:@"Authorization"];
	[signedRequest addValue:dateValue forHTTPHeaderField:@"Date"];
	
	return signedRequest;
}

@end
