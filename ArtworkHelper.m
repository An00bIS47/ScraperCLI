//
//  ArtworkHelper.m
//  SublerCLI
//
//  Created by michael on 16.01.15.
//
//

#import "ArtworkHelper.h"


@implementation ArtworkHelper

-(id) init;
{
	if (self = [super init]) {
		// Initialization code here
	}
	return self;
}


//////////////////////
// Get Size and Type of Artwork as Dict
// string	= poster, fanart, square, banner
// type		= 0 - 5
// width	= NSInteger
// height	= NSInteger
// aspectRatio = CGFloat
-(NSMutableDictionary *)getArtworkDict:(MP42Image *)curArtwork;
{
	
	NSArray * imageReps = [NSBitmapImageRep imageRepsWithData:curArtwork.data];
	
	NSInteger width = 0;
	NSInteger height = 0;
	
	ArtworkAspectType artworkAspectType = ArtworkAspectTypeUnknown;
	
	NSString *artworkString = nil;
	
	for (NSImageRep * imageRep in imageReps) {
		if ([imageRep pixelsWide] > width) width = [imageRep pixelsWide];
		if ([imageRep pixelsHigh] > height) height = [imageRep pixelsHigh];
	}
	
	
	CGFloat wFloat = [[NSNumber numberWithInteger:width] floatValue];
	CGFloat hFloat = [[NSNumber numberWithInteger: height] floatValue];
	CGFloat aspRatio = (wFloat / hFloat);
	NSMutableDictionary* resultDict = [[NSMutableDictionary alloc] init];
	
	// Poster: 800 x 1200
	// Aspect: 0.666
	if ((aspRatio > 0.6) && (aspRatio < 0.7)) {
		artworkString = @"poster";
		artworkAspectType = ArtworkAspectTypePoster;
	}
	
	// Banner: 758 x 140
	// Aspect: 5.414
	else if ((aspRatio > 5.3) && (aspRatio < 5.5)) {
		artworkString = @"banner";
		artworkAspectType = ArtworkAspectTypeBanner;
	}
	
	// Sqaure: 758 x 140
	// Aspect: 1.0
	else if ((aspRatio > 0.9) && (aspRatio < 1.1)) {
		artworkString = @"square";
		artworkAspectType = ArtworkAspectTypeSquare;
	}
	
	// Fanart: 720p
	else if ((width == 1280) && (height == 720)) {
		artworkString = @"fanart";
		artworkAspectType = ArtworkAspectTypeFanart;
	}
	
	// Fanart: 1080p
	else if ((width == 1920) && (height == 1080)) {
		artworkString = @"fanart";
		artworkAspectType = ArtworkAspectTypeFanart;
	}
	
	[resultDict setValue:artworkString forKey:@"string"];
	[resultDict setObject:[NSNumber numberWithInteger:artworkAspectType] forKey:@"type"];
	[resultDict setObject:[NSNumber numberWithFloat:aspRatio] forKey:@"aspectRatio"];
	[resultDict setObject:[NSNumber numberWithInteger:width] forKey:@"width"];
	[resultDict setObject:[NSNumber numberWithInteger:height] forKey:@"height"];
	
	return resultDict;
}

@end
