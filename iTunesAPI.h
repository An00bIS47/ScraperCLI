//
//  iTunesAPI.h
//  scraper
//
//  Created by michael on 09.01.15.
//  Copyright (c) 2015 michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"

@interface iTunesAPI : NSObject

@property (nonatomic, retain) NSDictionary *iTunesStoreCodes;

-(NSDictionary *) searchForTitle:(NSString *)aTitle
					   inCountry:(NSString *)aCountry
					   withLimit:(NSString *)aLimit;

-(NSDictionary *) lookupForID:(NSString *)aID
					inCountry:(NSString *)aCountry;

-(NSDictionary *) lookupCast:(NSString *)aUrl;

-(NSString *) getHighResArtworkUrl:(NSString *) aArtworkUrl;

-(void)saveImageFromUrl:(NSString *) aUrl
			inDirectory:(NSString *)aPath
		   withFilename:(NSString *) aFilename;

-(void) getImageFromURLAndSaveItToLocalData:(NSString *)imageName
									fileURL:(NSString *)fileURL
								inDirectory:(NSString *)directoryPath;

-(NSString *)getiTunesRatingString:(NSString *) aRating;
-(NSString *)getMPAARatingString:(NSString *) aRating;

@end
