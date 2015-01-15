//
//  iTunesAPI.m
//  scraper
//
//  Created by michael on 09.01.15.
//  Copyright (c) 2015 michael. All rights reserved.
//

#import "iTunesAPI.h"

@implementation iTunesAPI


-(id)init;
{
	if (self = [super init]) {
		// Initialization code here
		
		_iTunesStoreCodes = [[NSDictionary alloc] initWithObjectsAndKeys:@"143441", @"us",
							 @"143441", @"en",
							 @"143460", @"au",
							 @"143446", @"be",
							 @"143503", @"br",
							 @"143455", @"ca",
							 @"143458", @"dk",
							 @"143443", @"de",
							 @"143454", @"es",
							 @"143442", @"fr",
							 @"143448", @"gr",
							 @"143449", @"ie",
							 @"143450", @"it",
							 @"143462", @"jp",
							 @"143451", @"lu",
							 @"143452", @"nl",
							 @"143461", @"nz",
							 @"143457", @"no",
							 @"143453", @"pt",
							 @"143459", @"ch",
							 @"143447", @"fi",
							 @"143456", @"se",
							 @"143444", @"gb",
							 @"143469", @"ru",
							 nil];
		
	}
	return self;
}

//https://itunes.apple.com/search?term=matrix&entity=movie&country=de&limit=1

-(NSDictionary *) searchForTitle:(NSString *)aTitle inCountry:(NSString *)aCountry withLimit:(NSString *)aLimit;
{
	
	NSString *searchString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&country=%@&media=movie&limit=%@",aTitle, aCountry, aLimit];
	NSURL *url = [NSURL URLWithString:searchString];
	//	NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/search?term=matrix&entity=movie&country=de&limit=1"];
	NSMutableURLRequest *urlReq=[NSMutableURLRequest requestWithURL:url];
	NSURLResponse *response;
	NSError *error = nil;
	
	NSData *receivedData = [NSURLConnection sendSynchronousRequest:urlReq
											  returningResponse:&response
														  error:&error];
	
	
	if (error!=nil) {
		NSLog(@"web service error:%@",error);
	} else {
		if (receivedData !=nil) {
			
			NSError *Jerror = nil;
			NSDictionary* json =[NSJSONSerialization
								 JSONObjectWithData:receivedData
								 options:kNilOptions
								 error:&Jerror];
			
			
			
			//NSLog(@"json: %@", json);
			//NSLog(@"title: %@", [json valueForKeyPath:@"results.trackName"]);
			//NSLog(@"year: %@", [json valueForKeyPath:@"results.releaseDate"]);
			//NSLog(@"trackId: %@", [json valueForKeyPath:@"results.trackId"]);
			
			if (Jerror!=nil) {
				NSLog(@"json error:%@",Jerror);
				
				return nil;
			}
			
			return json;
		}
	}
	
	return nil;
}

-(NSDictionary *) lookupForID:(NSString *)aID inCountry:(NSString *)aCountry;
{
	//	https://itunes.apple.com/lookup?id=271469065&country=de
	NSString *searchString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@&country=%@",aID, aCountry];
	NSURL *url = [NSURL URLWithString:searchString];
	//	NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/search?term=matrix&entity=movie&country=de&limit=1"];
	NSMutableURLRequest *urlReq=[NSMutableURLRequest requestWithURL:url];
	NSURLResponse *response;
	NSError *error = nil;
	
	NSData *receivedData = [NSURLConnection sendSynchronousRequest:urlReq
											  returningResponse:&response
														  error:&error];
	
	
	if (error!=nil) {
		NSLog(@"web service error:%@",error);
	} else {
		if (receivedData !=nil) {
			
			NSError *Jerror = nil;
			NSDictionary* json =[NSJSONSerialization
								 JSONObjectWithData:receivedData
								 options:kNilOptions
								 error:&Jerror];
			
			
			
			//NSLog(@"json: %@", json);
			//			NSLog(@"title: %@", [json valueForKeyPath:@"results.trackName"]);
			//			NSLog(@"year: %@", [json valueForKeyPath:@"results.releaseDate"]);
			//			NSLog(@"trackId: %@", [json valueForKeyPath:@"results.trackId"]);
			
			if (Jerror!=nil) {
				NSLog(@"json error:%@",Jerror);
				
				return nil;
			}
			
			return json;
		}
	}
	
	return nil;
}



-(NSMutableDictionary *) lookupCast:(NSString *)aUrl;
{
	

	NSURL *url = [NSURL URLWithString:aUrl];
	NSData *htmlData = [NSData dataWithContentsOfURL:url];
 
	TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];
 
	// Actors
	NSString *actorsXpathQueryString = @"//div[@class='movie-description']/*/div[1]/ul/li/*/ul/li/a";
	NSArray *actorNodes = [htmlParser searchWithXPathQuery:actorsXpathQueryString];
	
	NSMutableArray *actorsArray = [[NSMutableArray alloc] initWithCapacity:[actorNodes count]];
	
	if ([actorNodes count] > 0) {
		for (TFHppleElement *element in actorNodes) {
			//NSLog(@"actor: %@",[[element firstChild] content]);
			[actorsArray addObject:[[element firstChild] content]];
		}
	}

	
	
	// Directors
	NSString *directorsXpathQueryString = @"//div[@class='movie-description']/*/div[2]/ul/li/*/ul/li/a";
	NSArray *directorNodes = [htmlParser searchWithXPathQuery:directorsXpathQueryString];
	NSMutableArray *directorsArray = [[NSMutableArray alloc] initWithCapacity:[directorNodes count]];
	
	if ([directorNodes count] > 0) {
		for (TFHppleElement *element in directorNodes) {
			//NSLog(@"director: %@",[[element firstChild] content]);
			[directorsArray addObject:[[element firstChild] content]];
		}
	}
	
	
	// Producer
	NSString *producerXpathQueryString = @"//div[@class='movie-description']/*/div[3]/ul/li/*/ul/li/a";
	NSArray *producerNodes = [htmlParser searchWithXPathQuery:producerXpathQueryString];
	NSMutableArray *producerArray = [[NSMutableArray alloc] initWithCapacity:[producerNodes count]];
	
	if ([producerNodes count] > 0) {
		for (TFHppleElement *element in producerNodes) {
			//NSLog(@"producer: %@",[[element firstChild] content]);
			[producerArray addObject:[[element firstChild] content]];
		}
	}
	
	// Copyright
	NSString *copyrightXpathQueryString = @"//div[@id='left-stack']/*/ul[@class='list']/li[@class='copyright']";
	NSArray *copyrightNodes = [htmlParser searchWithXPathQuery:copyrightXpathQueryString];
	NSMutableArray *copyrightArray = [[NSMutableArray alloc] initWithCapacity:[copyrightNodes count]];
	
	if ([copyrightNodes count] > 0) {
		for (TFHppleElement *element in copyrightNodes) {
			//NSLog(@"copyright: %@",[[element firstChild] content]);
			[copyrightArray addObject:[[element firstChild] content]];
		}
	}
	
	NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
	
	[result setObject:actorsArray forKey:@"actors"];
	[result setObject:directorsArray forKey:@"directors"];
	[result setObject:producerArray forKey:@"producers"];
	[result setObject:copyrightArray forKey:@"copyrights"];
	
	return result;
}

-(NSString *) getHighResArtworkUrl:(NSString *) aArtworkUrl;
{
	NSString *result;
	// http://a1.mzstatic.com/us/r30/Video/8d/e4/b3/mzi.hmmuutpp.100x100-75.jpg
	// http://a4.mzstatic.com/us/r30/Video/8d/e4/b3/mzi.hmmuutpp.jpg
	
	result = [aArtworkUrl stringByReplacingOccurrencesOfString:@".100x100-75.jpg"
													withString:@".jpg"];
	
	//result = [result stringByReplacingCharactersInRange:NSMakeRange(7, 2) withString:@"a4"];
	
	return result;
	
}

-(NSString *)getiTunesRatingString:(NSString *) aRating;
{
	//NSLog(@"Rating: %@",aRating);
	
	// English
	if ([@"NR" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"%@|%@|%@|",@"mpaa",@"NR",@"000"];
		return rating;
	}
	if ([@"G" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"%@|%@|%@|",@"mpaa",@"G",@"100"];
		return rating;
	}
	if ([@"PG" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"%@|%@|%@|",@"mpaa",@"PG",@"200"];
		return rating;
	}
	if ([@"PG-13" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"%@|%@|%@|",@"mpaa",@"PG-13",@"300"];
		return rating;
	}
	if ([@"R" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"%@|%@|%@|",@"mpaa",@"R",@"400"];
		return rating;
	}
	if ([@"NC-17" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"%@|%@|%@|",@"mpaa",@"NC-17",@"500"];
		return rating;
	}
	if ([@"Unrated" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"%@|%@|%@|",@"mpaa",@"Unrated",@"???"];
		return rating;
	}
	
	// German
	if ([@"Ab 0 Jahren" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"%@|%@|%@|",@"de-movie",@"Ab 0 Jahren",@"075"];
		return rating;
	}
	if ([@"Ab 6 Jahren" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"%@|%@|%@|",@"de-movie",@"Ab 6 Jahren",@"100"];
		return rating;
	}
	if ([@"Ab 12 Jahren" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"%@|%@|%@|",@"de-movie",@"Ab 12 Jahren",@"200"];
		return rating;
	}
	if ([@"Ab 16 Jahren" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"%@|%@|%@|",@"de-movie",@"Ab 16 Jahren",@"500"];
		return rating;
	}
	if ([@"Ab 18 Jahren" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"%@|%@|%@|",@"de-movie",@"Ab 18 Jahren",@"600"];
		return rating;
	}
	
	NSString *rating = [NSString stringWithFormat:@"%@|%@|%@|",@"mpaa",@"Unrated",@"???"];
	return rating;
}

-(NSString *)getMPAARatingString:(NSString *) aRating;
{
	//NSLog(@"Rating: %@",aRating);
	
	// English
	if ([@"NR" isEqualToString:aRating]) {
		return aRating;
	}
	if ([@"G" isEqualToString:aRating]) {
		return aRating;
	}
	if ([@"PG" isEqualToString:aRating]) {
		return aRating;
	}
	if ([@"PG-13" isEqualToString:aRating]) {
		return aRating;
	}
	if ([@"R" isEqualToString:aRating]) {
		return aRating;
	}
	if ([@"NC-17" isEqualToString:aRating]) {
		return aRating;
	}
	if ([@"Unrated" isEqualToString:aRating]) {
		return aRating;
	}
	
	// German
	if ([@"Ab 0 Jahren" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"Germany:0"];
		return rating;
	}
	if ([@"Ab 6 Jahren" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"Germany:6"];
		return rating;
	}
	if ([@"Ab 12 Jahren" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"Germany:12"];
		return rating;
	}
	if ([@"Ab 16 Jahren" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"Germany:16"];
		return rating;
	}
	if ([@"Ab 18 Jahren" isEqualToString:aRating]) {
		NSString *rating = [NSString stringWithFormat:@"Germany:18"];
		return rating;
	}
	
	NSString *rating = [NSString stringWithFormat:@"Unrated"];
	return rating;
}

-(void)saveImageFromUrl:(NSString *) aUrl inDirectory:(NSString *)aPath withFilename:(NSString *) aFilename;
{
	//NSString * documentsDirectoryPath = @"/Users/michael/Desktop/";
	NSString *imgName = aFilename;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *writablePath = [aPath stringByAppendingPathComponent:aFilename];
	
	if(![fileManager fileExistsAtPath:writablePath]){
		// file doesn't exist
		//NSLog(@"file doesn't exist");
		if (imgName) {
			//save Image From URL
			[self getImageFromURLAndSaveItToLocalData:aFilename fileURL:aUrl inDirectory:aPath];
		}
	}
	else{
		// file exist
		//NSLog(@"file exist");
	}
}

-(void) getImageFromURLAndSaveItToLocalData:(NSString *)imageName fileURL:(NSString *)fileURL inDirectory:(NSString *)directoryPath;
{
	NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
	
	NSError *error = nil;
	[data writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", imageName]] options:NSAtomicWrite error:&error];
	
	if (error) {
		NSLog(@"Error Writing File : %@",error);
	}else{
		//NSLog(@"Image %@ Saved SuccessFully",imageName);
	}
}

@end
