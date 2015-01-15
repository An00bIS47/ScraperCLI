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


//void writeXML(Movie *currentMovie, NSString *filePath)
//{
//	NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"movie"];
//	NSXMLDocument *xmlDoc = [NSXMLDocument documentWithRootElement:root];
//	[xmlDoc setVersion:@"1.0"];
//	[xmlDoc setCharacterEncoding:@"UTF-8"];
//	[xmlDoc setStandalone:YES];
//	
//	//	[root addAttribute:[NSXMLNode attributeWithName:@"Attribute1" stringValue:@"Value1"]];
//	//	[root addAttribute:[NSXMLNode attributeWithName:@"Attribute2" stringValue:@"Value2"]];
//	//	[root addAttribute:[NSXMLNode attributeWithName:@"Attribute3" stringValue:@"Value3"]];
//	
//	
//	//	NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
//	
//	//	[root addChild:[NSXMLNode commentWithStringValue:@"Hello world!"]];
//	
//	
//	NSXMLElement *childElement = [[NSXMLElement alloc] initWithName:@"title" stringValue:currentMovie.title];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"originaltitle" stringValue:currentMovie.title];
//	[root addChild:childElement];
//	
//	//	childElement = [[NSXMLElement alloc] initWithName:@"outline" stringValue:currentMovie.shortDescription];
//	//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"plot" stringValue:currentMovie.plot];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"mpaa" stringValue:currentMovie.mpaa];
//	[root addChild:childElement];
//
//	childElement = [[NSXMLElement alloc] initWithName:@"id" stringValue:currentMovie.imdbid];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"itunesid" stringValue:currentMovie.itunesid];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"rating" stringValue:currentMovie.rating];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"year" stringValue:currentMovie.year];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"top250" stringValue:currentMovie.top250];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"votes" stringValue:currentMovie.votes];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"outline" stringValue:currentMovie.outline];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"tagline" stringValue:currentMovie.tagline];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"runtime" stringValue:currentMovie.runtime];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"playcount" stringValue:currentMovie.playcount];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"lastplayed" stringValue:currentMovie.lastplayed];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"set" stringValue:currentMovie.set];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"premiered" stringValue:currentMovie.premiered];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"status" stringValue:currentMovie.status];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"code" stringValue:currentMovie.code];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"aired" stringValue:currentMovie.aired];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"dateadded" stringValue:currentMovie.dateadded];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"copyright" stringValue:currentMovie.copyright];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"trailer" stringValue:currentMovie.trailer];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"kind" stringValue:currentMovie.kind];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"artistname" stringValue:currentMovie.artistname];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"releasedate" stringValue:currentMovie.releasedate];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"studio" stringValue:currentMovie.studio];
//	[root addChild:childElement];
//	
//	childElement = [[NSXMLElement alloc] initWithName:@"mpaaitunes" stringValue:currentMovie.mpaaiTunes];
//	[root addChild:childElement];
//
//	childElement = [[NSXMLElement alloc] initWithName:@"contentadvisoryrating" stringValue:currentMovie.contentAdvisoryRating];
//	[root addChild:childElement];
//	
//	// Genres
//	for (NSString *genre in currentMovie.genres) {
//		childElement = [[NSXMLElement alloc] initWithName:@"genre" stringValue:genre];
//		[root addChild:childElement];
//	}
//	
//	// country
//	for (NSString *country in currentMovie.countries) {
//		childElement = [[NSXMLElement alloc] initWithName:@"country" stringValue:country];
//		[root addChild:childElement];
//	}
//	
//	// Credits
//	for (Actor *producer in currentMovie.producers) {
//		childElement = [[NSXMLElement alloc] initWithName:@"credits" stringValue:producer.name];
//		[root addChild:childElement];
//	}
//	
//	// Directors
//	for (Actor *director in currentMovie.directors) {
//		childElement = [[NSXMLElement alloc] initWithName:@"director" stringValue:director.name];
//		[root addChild:childElement];
//	}
//	
//	// Thumbs
//	for (Thumb *thumb in currentMovie.thumbs) {
//		childElement = [[NSXMLElement alloc] initWithName:@"thumb" stringValue:thumb.value];
//		
//		if (![thumb.aspect isEqualToString:@""]) {
//			[childElement addAttribute:[NSXMLNode attributeWithName:@"aspect" stringValue:thumb.aspect]];
//		}
//		if (![thumb.preview isEqualToString:@""]) {
//			[childElement addAttribute:[NSXMLNode attributeWithName:@"preview" stringValue:thumb.preview]];
//		}
//		[root addChild:childElement];
//	}
//	
//	// Fanarts
//	if ([currentMovie.fanarts count] > 0) {
//		childElement = [[NSXMLElement alloc] initWithName:@"fanart"];
//
//		for (Thumb *thumb in currentMovie.fanarts) {
//			
//			NSXMLElement *nameElement = [[NSXMLElement alloc] initWithName:@"thumb" stringValue:thumb.value];
//			
//			if (![thumb.aspect isEqualToString:@""]) {
//				[nameElement addAttribute:[NSXMLNode attributeWithName:@"aspect" stringValue:thumb.aspect]];
//			}
//			if (![thumb.preview isEqualToString:@""]) {
//				[nameElement addAttribute:[NSXMLNode attributeWithName:@"preview" stringValue:thumb.preview]];
//			}
//			[childElement addChild:nameElement];
//			
//		}
//		[root addChild:childElement];
//	}
//
//	
//	// Actors
//	for (Actor *actor in currentMovie.actors) {
//		childElement = [[NSXMLElement alloc] initWithName:@"actor"];
//
//		NSXMLElement *nameElement = [[NSXMLElement alloc] initWithName:@"name" stringValue:actor.name];
//		[childElement addChild:nameElement];
//
//		NSXMLElement *roleElement = [[NSXMLElement alloc] initWithName:@"role" stringValue:actor.role];
//		[childElement addChild:roleElement];
//		
//		NSXMLElement *orderElement = [[NSXMLElement alloc] initWithName:@"order" stringValue:actor.order];
//		[childElement addChild:orderElement];
//
//		NSXMLElement *thumbElement = [[NSXMLElement alloc] initWithName:@"thumb" stringValue:actor.thumb];
//		[childElement addChild:thumbElement];
//		
//		[root addChild:childElement];
//	}
//	
////	NSXMLElement *childElement2 = [[NSXMLElement alloc] initWithName:@"ChildElement2"];
////	[childElement2 addAttribute:[NSXMLNode attributeWithName:@"ChildAttribute2.1" stringValue:@"Value2.1"]];
////	[childElement2 setStringValue:@"ChildValue2.1"];
////	[root addChild:childElement2];
//	
//	
//
//	
////	NSLog(@"XML Document\n%@", xmlDoc);//till this art code runs fine.
//	NSData *xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
//	
//	[[NSFileManager defaultManager] createFileAtPath:filePath contents:xmlData attributes:nil];
//	
////	file = [NSFileHandle fileHandleForUpdatingAtPath: filePath];
////	//set writing path to file
////	if (file == nil) //check file present or not in file
////		NSLog(@"Failed to open file");
////	//[file seekToFileOffset: 6];
////	//object pointer initialy points the offset as 6 position in file
////	[file writeData: xmlData];
////	//writing data to new file
////	[file closeFile];
//	
//	//	[xmlData writeToFile:@"/Users/halen/Documents/project3/xmlsample.xml" atomically:YES];
//}


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
	if ([elementname isEqualToString:@"movie"]) {
		currentMovie = [[Movie alloc] init];
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
		currentMovie.kind = currentNodeContent;
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
		currentNodeContent = nil;
	}
	if ([elementname isEqualToString:@"studio"])
	{
		currentMovie.studio = currentNodeContent;
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

	if ([elementname isEqualToString:@"movie"])
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
