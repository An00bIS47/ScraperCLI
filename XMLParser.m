//
//  XMLParser.m
//  scraper
//
//  Created by michael on 08.01.15.
//  Copyright (c) 2015 michael. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser

//@synthesize movies;
//@synthesize actors;

NSMutableArray *movies;
NSMutableArray *actors;
NSMutableArray *producers;
NSMutableArray *thumbs;
NSMutableArray *fanarts;
NSMutableArray *genres;
NSMutableArray *countries;
NSMutableArray *credits;
NSMutableArray *directors;

//- (id) init {
//	if (self = [super init]) {
//		movies			= [[NSMutableArray alloc] init];
//		actors			= [[NSMutableArray alloc] init];
//	}
//	return self;
//}

-(NSMutableArray *) getMovies {
	return movies;
}


-(NSMutableArray *) getActors {
	return actors;
}

-(NSMutableArray *) getThumbs {
	return thumbs;
}

-(NSMutableArray *) getFanarts {
	return fanarts;
}





-(Movie *) loadXMLByPath:(NSString *)pathString;
{
	//NSString *path=@"/Users/michael/Desktop/Movies/Matrix/movie.nfo";  //this is ur path of xml file
	NSString *path=pathString;
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	
	//NSURL *url      = [[NSURL alloc] initFileURLWithPath:pathString];
	NSError *error;
	NSString * dataString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
	parser = [[NSXMLParser alloc] initWithData:data ];
	
	//parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	
	XMLParser *theDelegate = [[XMLParser alloc] init];
	[parser setDelegate:theDelegate];
	[parser parse];
	// parser.delegate = self;
	//[parser parse];
	
//	NSLog(@"movies loadxml: %@", movies);
	return [movies objectAtIndex:0];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	movies = [[NSMutableArray alloc] init];
	actors = [[NSMutableArray alloc] init];
	thumbs = [[NSMutableArray alloc] init];
	fanarts = [[NSMutableArray alloc] init];
	genres = [[NSMutableArray alloc] init];
	countries = [[NSMutableArray alloc] init];
	directors = [[NSMutableArray alloc] init];
	producers = [[NSMutableArray alloc] init];
	credits = [[NSMutableArray alloc] init];
	
	currentNodeContent = nil;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementname namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if ([elementname isEqualToString:@"movie"] && [attributeDict count] == 0 ) {
		currentMovie = [[Movie alloc] init];
		depth = 0;
	} else if ([elementname isEqualToString:@"movie"] && [attributeDict count] != 0 ) {
		depth = 1;
	} else if ([elementname isEqualToString:@"recommendations"]) {
		depth = 1;
	} else if ([elementname isEqualToString:@"actor"]) {
		currentActor = [[Actor alloc] init];
		depth = 1;
	} else if ([elementname isEqualToString:@"director"]) {
		currentDirector = [[Actor alloc] init];
	} else if ([elementname isEqualToString:@"credits"]) {
		currentProducer = [[Actor alloc] init];
	} else if (([elementname isEqualToString:@"thumb"]) && (depth == 0)) {

		currentThumb = [[Thumb alloc] init];
		NSString *attrAspect=[attributeDict valueForKey:@"aspect"];
		NSString *attrPreview=[attributeDict valueForKey:@"preview"];
		
		if (attrAspect) {
			currentThumb.aspect = attrAspect;
		}
		
		if (attrAspect) {
			currentThumb.preview = attrPreview;
		}
		
		depth = 2;
	} else if ([elementname isEqualToString:@"fanart"]) {
		currentFanart = [[Thumb alloc] init];
		depth = 3;
	} else if (([elementname isEqualToString:@"thumb"]) && (depth == 3)) {
		
		NSString *attrAspect=[attributeDict valueForKey:@"aspect"];
		NSString *attrPreview=[attributeDict valueForKey:@"preview"];
		
		if (attrAspect) {
			currentFanart.aspect = attrAspect;
		}
		
		if (attrAspect) {
			currentFanart.preview = attrPreview;
		}
		
		//depth = 4;
	}
	

}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementname namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	
	currentNodeContent = (NSMutableString *) [currentNodeContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[currentNodeContent stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
	
	if ([elementname isEqualToString:@"title"])
	{
		currentMovie.title = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"originaltitle"])
	{
		currentMovie.originaltitle = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"rating"])
	{
		currentMovie.rating = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"year"])
	{
		currentMovie.year = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"top250"])
	{
		currentMovie.top250 = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"votes"])
	{
		currentMovie.votes = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"outline"])
	{
		currentMovie.outline = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"plot"])
	{
		currentMovie.plot = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"tagline"])
	{
		currentMovie.tagline = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"runtime"])
	{
		currentMovie.runtime = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"mpaa"])
	{
		currentMovie.mpaa = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"playcount"])
	{
		currentMovie.playcount = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"lastplayed"])
	{
		currentMovie.lastplayed = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"id"])
	{
		currentMovie.imdbid = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"tmdbid"])
	{
		currentMovie.tmdbid = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"tvdbid"])
	{
		currentMovie.tvdbid = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"itunesid"])
	{
		currentMovie.itunesid = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"set"])
	{
		currentMovie.set = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"premiered"])
	{
		currentMovie.premiered = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"status"])
	{
		currentMovie.status = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"code"])
	{
		currentMovie.code = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"aired"])
	{
		currentMovie.aired = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"studio"])
	{
		currentMovie.studio = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"dateadded"])
	{
		currentMovie.dateadded = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"copyright"])
	{
		currentMovie.copyright = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"trailer"])
	{
		currentMovie.trailer = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"kind"])
	{
		if ([currentNodeContent isEqualToString:@"9"]) {
			currentMovie.kind = MP4MediaTypeMovie;
		}

		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"artistname"])
	{
		currentMovie.artistname = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"releasedate"])
	{
		currentMovie.releasedate = currentNodeContent;
		currentMovie.year = [currentMovie.releasedate substringWithRange: NSMakeRange (0, 4)];
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"studio"])
	{
		currentMovie.studio = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"contentid"])
	{
		currentMovie.contentID = (long)currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"storeid"])
	{
		currentMovie.storeID = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"contentadvisoryrating"])
	{
		currentMovie.contentAdvisoryRating = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"mpaaitunes"])
	{
		currentMovie.mpaaiTunes = currentNodeContent;
		currentNodeContent = nil;
	}
	
	// Genres
	if ([elementname isEqualToString:@"genre"])
	{
		[genres addObject:currentNodeContent];
		currentNodeContent = nil;
	}
	
	// Coutries
	if ([elementname isEqualToString:@"country"])
	{
		[countries addObject:currentNodeContent];
		currentNodeContent = nil;
	}
	
	// Directors
	if ([elementname isEqualToString:@"director"])
	{
		currentDirector.name = currentNodeContent;
		[directors addObject:currentDirector];
		currentDirector = nil;
		currentNodeContent = nil;
	}
	// Producers
	if ([elementname isEqualToString:@"producer"])
	{
		currentProducer.name = currentNodeContent;
		[producers addObject:currentProducer];
		currentProducer = nil;
		currentNodeContent = nil;
	}
	// Credits
	if ([elementname isEqualToString:@"credits"])
	{
		currentProducer.name = currentNodeContent;
		[producers addObject:currentProducer];
		currentProducer = nil;
		currentNodeContent = nil;
	}
	
	// Actors
	if (([elementname isEqualToString:@"role"]) && (depth == 1))
	{
		currentActor.role = currentNodeContent;
		currentNodeContent = nil;
	}
	if (([elementname isEqualToString:@"name"]) && (depth == 1))
	{
		currentActor.name = currentNodeContent;
		currentNodeContent = nil;
	}
	if (([elementname isEqualToString:@"order"]) && (depth == 1))
	{
		currentActor.order = currentNodeContent;
		currentNodeContent = nil;
	}
	if (([elementname isEqualToString:@"thumb"]) && (depth == 1))
	{
		currentActor.thumb = currentNodeContent;
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"actor"])
	{
		[actors addObject:currentActor];
		currentActor = nil;
		currentNodeContent = nil;
		depth = 0;
	}
	
	// Thumbs
	if (([elementname isEqualToString:@"thumb"]) && (depth == 2))
	{
		currentThumb.value = currentNodeContent;
		[thumbs addObject:currentThumb];
		currentNodeContent = nil;
		depth=0;
	}
	
	// Fanarts
	if (([elementname isEqualToString:@"thumb"]) && (depth == 3))
	{
		currentFanart.value = currentNodeContent;
		[fanarts addObject:currentFanart];
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"fanart"])
	{
		depth=0;
	}
	if ([elementname isEqualToString:@"recommendations"])
	{
		depth=0;
	}
	if (([elementname isEqualToString:@"movie"]) && (depth == 0))
	{

		currentMovie.actors = actors;
		currentMovie.directors = directors;
		currentMovie.producers = producers;
		currentMovie.thumbs = thumbs;
		currentMovie.fanarts = fanarts;
		currentMovie.genres = genres;
		currentMovie.countries = countries;
		currentMovie.producers = credits;
		
		
		[movies addObject:currentMovie];
		currentMovie = nil;
		currentNodeContent = nil;
	}
	currentNodeContent = nil;
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	//currentNodeContent = (NSMutableString *) [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (!currentNodeContent) {
		// init the ad hoc string with the value
		currentNodeContent = [[NSMutableString alloc] initWithString:string];
	} else {
		// append value to the ad hoc string
		[currentNodeContent appendString:string];
	}
}
@end
