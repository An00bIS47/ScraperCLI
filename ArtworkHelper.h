//
//  ArtworkHelper.h
//  SublerCLI
//
//  Created by michael on 16.01.15.
//
//

#import <Foundation/Foundation.h>
#import "MP42File.h"
#import "MP42FileImporter.h"

typedef enum {
	ArtworkAspectTypeUnknown = 0,
	ArtworkAspectTypePoster = 1,
	ArtworkAspectTypeBanner = 2,
	ArtworkAspectTypeSquare = 3,
	ArtworkAspectTypeFanart = 4
} ArtworkAspectType;

@interface ArtworkHelper : NSObject

-(id) init;
-(NSMutableDictionary *)getArtworkDict:(MP42Image *)curArtwork;

@end
