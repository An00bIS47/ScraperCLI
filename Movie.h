//
//  Movie.h
//  scraper
//
//  Created by michael on 08.01.15.
//  Copyright (c) 2015 michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "Thumb.h"
#import <AppKit/AppKit.h>

typedef enum {
	MP4MediaTypeMovie = 9,
	MP4MediaTypeTvShow = 10
} MP4MediaType;

@interface Movie : NSObject
										// Elememt			//	   xbmc nfo		|	iTunes						>>> Model
@property (nonatomic, retain) NSString* title;				//					|
@property (nonatomic, retain) NSString* originaltitle;		//					|	NA
@property (nonatomic, retain) NSString* rating;				//					|	??
@property (nonatomic, retain) NSString* year;				//					|	releaseDate
@property (nonatomic, retain) NSString* top250;				//					|	NA
@property (nonatomic, retain) NSString* votes;				//					|	NA
@property (nonatomic, retain) NSString* outline;			//					|	shortDescription
@property (nonatomic, retain) NSString* plot;				//					|	longDescription
@property (nonatomic, retain) NSString* tagline;			//					|	NA
@property (nonatomic, retain) NSString* runtime;			//					|	??
@property (nonatomic, retain) NSString* mpaa;				//					|	contentAdvisoryRating
@property (nonatomic, retain) NSString* playcount;			//					|	??
@property (nonatomic, retain) NSString* lastplayed;			//					|	??
@property (nonatomic, retain) NSString* imdbid;				//		id			|	imdbid
@property (nonatomic, retain) NSString* tmdbid;				//		tmdbd		|	tmdbd
@property (nonatomic, retain) NSString* tvdbid;				//		tvdbid		|	tvdbid
@property (nonatomic, retain) NSString* itunesid;			//		itunesid	|	itunesid
@property (nonatomic, retain) NSString* set;				//					|	NA
@property (nonatomic, retain) NSString* premiered;			//					|	NA
@property (nonatomic, retain) NSString* status;				//		??			|	NA
@property (nonatomic, retain) NSString* code;				//		??			|	NA
@property (nonatomic, retain) NSString* aired;				//		??			|	NA
@property (nonatomic, retain) NSString* studio;				//					|	NA
@property (nonatomic, retain) NSString* dateadded;			//		??			|	NA
@property (nonatomic, retain) NSString* copyright;			//		NA			|
@property (nonatomic, retain) NSString* trailer;			//					|	previewUrl
//@property (nonatomic, retain) NSString* kind;				//		NA			|	kind
@property (nonatomic, retain) NSString* artistname;			//		NA			|	artistName
@property (nonatomic, retain) NSString* releasedate;		//		NA			|	releaseDate
@property (nonatomic, retain) NSString* contentAdvisoryRating;//				|	contentAdvisoryRating
@property (nonatomic, retain) NSString* mpaaiTunes;			//		NA			|	
// to implement in nfo reading and writing
@property (nonatomic, retain) NSString* comments;			//					|	comments
@property (nonatomic, retain) NSString*	shortdescription;	//					|	shortDescription
@property					  BOOL		hd;					//					|	hd
@property (nonatomic, retain) NSString* screenformat;		//					|	screenFormat
@property					  NSInteger contentID;			//					|	cnID
@property					  MP4MediaType kind;			//					|	kind
@property (nonatomic, retain) NSImage*	artwork;			//					|	artwork
// end to implement

@property (nonatomic, retain) NSArray* genres;				//		genre		|	primaryGenreName
//	<genre></genre>
//	<genre></genre>
//	<genre></genre>
@property (nonatomic, retain) NSArray* actors;				//		actor		|	actor						>>> Actor
//	<actor>
//		<name></name>
//		<role></role>
//		<order></order>
//		<thumb></thumb>
//	</actor>
@property (nonatomic, retain) NSArray* directors;			//		director	|	director
//	<director></director>
//	<director></director>
//	<director></director>
@property (nonatomic, retain) NSArray* producers;			//		credits		|	producer
//	<credits></credits>
//	<credits></credits>
//	<credits></credits>
@property (nonatomic, retain) NSArray* thumbs;				//		thumb		|	artworkUrl					>>> Thumb
//	<thumb aspect="" preview=""></thumb>
//	<thumb aspect="" preview=""></thumb>
//	<thumb aspect="" preview=""></thumb>
@property (nonatomic, retain) NSArray* fanarts;				//		fanart		|	NA / ??						>>> Thumb
//	<fanart>
//		<thumb preview=""></thumb>			// without aspect
//		<thumb preview=""></thumb>			// without aspect
//		<thumb preview=""></thumb>			// without aspect
//	</fanart>
@property (nonatomic, retain) NSArray* countries;			//		country		|	NA
//	<country></country>
//	<country></country>
//	<country></country>
@end
