//
//  Movie.m
//  scraper
//
//  Created by michael on 08.01.15.
//  Copyright (c) 2015 michael. All rights reserved.
//

#import "Movie.h"

@implementation Movie

-(id) init;
{
	if (self = [super init]) {
		// Initialization code here
		_title = @"";
		_originaltitle = @"";
		_rating = @"";
		_year = @"";
		_top250 = @"";
		_votes = @"";
		_outline = @"";
		_plot = @"";
		_tagline = @"";
		_runtime = @"";
		_mpaa = @"";
		_playcount = @"";
		_lastplayed = @"";
		_imdbid = @"";
		_tmdbid = @"";
		_tvdbid = @"";
		_itunesid = @"";
		_set = @"";
		_premiered = @"";
		_status = @"";
		_code = @"";
		_aired = @"";
		_studio = @"";
		_dateadded = @"";
		_copyright = @"";
		_trailer = @"";
		//_kind = @"";
		_artistname = @"";
		_releasedate = @"";
		_contentAdvisoryRating = @"";
		_mpaaiTunes = @"";
		_comments = @"";
		_shortdescription=@"";
		_hd = false;
		_screenformat = @"";
		_kind = MP4MediaTypeMovie;
		_artwork = [[MP42Image alloc] init];
		_contentID = 0;
		_storeID = @"";
		
		_actors = [[NSArray alloc] init];
		_genres = [[NSArray alloc] init];
		_directors = [[NSArray alloc] init];
		_producers = [[NSArray alloc] init];
		_fanarts = [[NSArray alloc] init];
		_thumbs = [[NSArray alloc] init];
		_countries = [[NSArray alloc] init];
		_artworks = [[NSArray alloc] init];
	}
	return self;
}


@end
