//
//  XMLParser.h
//  scraper
//
//  Created by michael on 08.01.15.
//  Copyright (c) 2015 michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"
#import "Thumb.h"

@interface XMLParser : NSObject <NSXMLParserDelegate>
{
	NSMutableString	*currentNodeContent;

	NSXMLParser		*parser;

	int				depth;
	Actor			*currentActor;
	Actor			*currentDirector;
	Actor			*currentProducer;
	Movie			*currentMovie;
	Thumb			*currentThumb;
	Thumb			*currentFanart;
}
//@property NSMutableArray	*movies;
//@property NSMutableArray	*actors;

-(Movie *) loadXMLByPath:(NSString *)pathString;
//void writeXML(Movie *currentMovie, NSString *filePath);

-(NSMutableArray *) getMovies;
-(NSMutableArray *) getActors;
-(NSMutableArray *) getThumbs;
-(NSMutableArray *) getFanarts;

@end
