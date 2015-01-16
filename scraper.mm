//
//  SublerCLI.mm
//  Subler
//
//  Copyright 2009-2013 Damiano Galassi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Movie.h"
#import "XMLParser.h"
#import "iTunesAPI.h"

#import "MP42File.h"
#import "MP42FileImporter.h"
#import "RegexKitLite.h"
#import "JSONKit.h"

#define APPNAME					"scraper"
#define APPVERSION				0.1
#define PROGRESSBAR_MAX_CALLS	1000
#define PROGRESSBAR_WIDTH		40
#define DEBUG 1

XMLParser *xmlParser;
BOOL			verbose			= false;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Command Line Arguments
//

void print_help() {
	printf("%s usage:\n", APPNAME);
	printf("\n");
	printf("\t -i, -input <file>        URL of source file					\n");
	printf("\n");
	printf("nfo Options:\n");
	printf("\t -n, -nfo <nfo file>      URL of nfo file	to read				\n");
	printf("\t -w, -writenfo            Create nfo file						\n");
	printf("\t -O, -overwritenfo        Overwrite nfo file					\n");
	printf("\t -I, -ignorenfo           Don't read nfo file					\n");
	
	printf("\n");
	printf("Metadata Options:\n");
	printf("\t -lm, -listmetadata        List metadata								\n");
	printf("\t -it, -ignoretags          Ignore tags								\n");
	printf("\t -t,  -tag				 Tag file with data from nfo or scraper		\n");
	printf("\t -e,  -extract <png file>	 Extract artwork to <png file>				\n");
	printf("\t -ed, -extractdefault 	 Extract artwork to <movie>-poster.png		\n");
	
	printf("\n");
	printf("Scraper Options:\n");
	printf("\t -T, -title <title>       Title for lookup					\n");
	printf("\t -c, -country <cc>        Country Code for lookup e.g. de		\n");
	printf("\t -C, -listcc              List available country codes		\n");
	printf("\t -L, -limit               Limit search results (default: 1)	\n");
	printf("\t -N, -nolookup            Don't lookup, just read nfo			\n");
	
	printf("\n");
	printf("Mode Options:\n");
	printf("\t -u, -unattended          No user interactions, skip			\n");
	printf("\t -r, -remove              Remove nfo and artwork from disk	\n");
	
	printf("\n");
	printf("Misc Options:\n");
	printf("\t -h, -help                Show help							\n");
	printf("\t -V, -version             Show version						\n");
	printf("\t -v, -verbose             Verbose output						\n");
	printf("\t -W, -workflow            Show workflow						\n");
	printf("\n");
	printf("\n");
	printf("Recommended Directory Structure:\n");
	printf("\n");
	printf("<All Movies>\n");
	printf("[----<Matrix>\n");
	printf("		[----<Matrix>.m4v\n");
	printf("[----<Prestige>\n");
	printf("		[----<foobar>.m4v\n");
	printf("\n");
	printf("The title for lookups is the name of parent directory of the m4v file or the title given via tag/nfo or via commandline argument.	\n");
	printf("\n");
	printf("Examples: \n");
	printf("Lookup for the title <Matrix> (show max 10 results) and tag the file but ignore embedded tags: \n");
	printf("scraper -input \"/path/to/file.m4v\" -country de -limit 10 -tag	-title \"Matrix\"	\n");
	printf("scraper -i \"/path/to/file.m4v\" -c de -L 10 -t	-T \"Matrix\"						\n");
	printf("\n");
	printf("Read tags from a file and create a nfo file for xbmc with embedded artwork as <movie>-poster.png \n");
	printf("scraper -i \"/path/to/file.m4v\" -nolookup -writenfo -extractdefault	\n");
	printf("\n");
	printf("Tag all m4v files from the infos of the nfo files								\n");
	printf("scraper -i \"/Users/username/iTunes/Movies/\" -it -t								\n");
	printf("\n");
	printf("Lookup, create new nfo, tag, save Artwork for all movies in this directory without user interaction:								\n");
	printf("scraper -i \"/Users/username/iTunes/Movies/\" -it -t	-c de -u -w -O -ed -I							\n");
	printf("\n");
	printf("list metadata:								\n");
	printf("scraper -i \"/Users/username/iTunes/Movies/Matrix/Matrix.m4v\" -lm									\n");
	printf("\n");
	printf("\n");
}


void print_version() {
	printf("Version: %.1f \n", APPVERSION);
}

void print_cc() {
	printf("All available country codes: \n");
	iTunesAPI *itunesAPI = [[iTunesAPI alloc] init];
	
	NSArray *cCodes = [[itunesAPI iTunesStoreCodes] allKeys];
	
	for (NSString *cCode in cCodes) {
		//NSLog(@"%@",cCode);
		printf("%s ", [cCode UTF8String]);
	}
	printf("\n");
}

void print_workflow(){
	printf("%s workflow:		\n", APPNAME);
	printf("     ___       ____      ____          ___       ____		\n");
	printf("  |8|   |8|   |    |    /    \\      |8|   |8|   |    |		\n");
	printf("  |8|m4v|8| + | nfo| + |iTunes| >>> |8|m4v|8| + | nfo|		\n");
	printf("  |8|___|8|   |____|    \\____/      |8|___|8|   |____|		\n");
	printf("															\n");
	printf("  Get info from tags										\n");
	printf("            + nfo and overwrite info						\n");
	printf("                     + iTunes and overwrite info			\n");
	printf("                                >>> Write tags				\n");
	printf("                                              + new nfo		\n");
	printf("															\n");
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Helper Functions
//
// Process has done x out of n rounds,
// and we want a bar of width w and resolution r.
static void progressBar(int x, int n, int r, int w, NSString* aString, NSString* aDesc)
{
	// Only update r times.
	if ( x % (n/r +1) != 0 ) return;
 
	// Calculuate the ratio of complete-to-incomplete.
	float ratio = x/(float)n;
	int   c     = ratio * w;
 
	// Show the percentage complete.
	printf("%s %3d%% [", [aString UTF8String], (int)(ratio*100) );
 
	// Show the load bar.
	for (int x=0; x<c; x++)
		printf("=");
 
	for (int x=c; x<w; x++)
		printf(" ");
 
	// ANSI Control codes to go back to the
	// previous line and clear it.
	if (x != 0) {
		printf("]  %s \n\033[F\033[J", [aDesc UTF8String]);
	}
	
	
	if ((ratio*100) == 100) {
		printf("%s OK\n",[aString UTF8String]);
	}
}


NSInteger indexOfITunesCodes(NSString *aRatingString, NSArray *iTunesCodes) {
	
	NSString *splitElements  = @"\\|";
	NSArray *ratingItems = [aRatingString componentsSeparatedByRegex:splitElements];
	NSInteger indexForItunesCode = 0;
	
	if ([ratingItems count] > 2){
		NSInteger counter = 0;
		
		for (NSString *curiTunesCode in iTunesCodes) {
			if ([curiTunesCode isEqualToString:aRatingString]) {
				indexForItunesCode = counter;
				return indexForItunesCode;
			}
			counter++;
		}
		
		
	} else {
		//ratingiTunesCode = nil;
		NSInteger counter = 0;
		for (NSString *curiTunesCode in iTunesCodes) {
				NSString *splitElements  = @"\\|";
				NSArray *ratingItems = [curiTunesCode componentsSeparatedByRegex:splitElements];
				
				//de-movie|Ab 12 Jahren|200|
				if ([[ratingItems objectAtIndex:1] isEqualToString:aRatingString]) {
					indexForItunesCode = counter;
					return indexForItunesCode;
				}
			
			counter++;
		}
		
	}
	
	return indexForItunesCode;
}

NSArray* getAllFiles(NSString *path, NSString *aExt){
	NSString* file;
	NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
	NSMutableArray* allFiles = [[NSMutableArray alloc] init];
	
	while (file = [enumerator nextObject])
	{
		// check if it's a directory
		BOOL isDirectory = NO;
		[[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat:@"%@/%@",path,file]
											 isDirectory: &isDirectory];
		if (!isDirectory) {
			// open your file …
			
			NSString *tempExt = [NSString stringWithFormat:@".%@", aExt];
			if (![file hasPrefix:@"."]) {
				if ([file hasSuffix:tempExt]) {
					[allFiles addObject:[NSString stringWithFormat:@"%@%@",path,file]];
				}
			}
			
		} else {
			if (![file hasPrefix:@"."]) {
				[allFiles addObjectsFromArray:getAllFiles(file, aExt)];
			}
		}
	}
	return allFiles;
}

void removeData(NSString *inputFilename){
	NSMutableArray *nfoFiles = [[NSMutableArray alloc] init];
	NSMutableArray *jpgFiles = [[NSMutableArray alloc] init];
	NSMutableArray *pngFiles = [[NSMutableArray alloc] init];
	BOOL isDir = NO;
	NSError *error = nil;
	
	printf("Cleaning Metadata from Directory...\n");
	
	if (inputFilename == nil) {
		printf("Error: Please specify input file or directory!\n");
	}
	
	if([[NSFileManager defaultManager] fileExistsAtPath:inputFilename isDirectory:&isDir] && isDir){
		//NSLog(@"Is directory");
		
		nfoFiles = [NSMutableArray arrayWithArray:getAllFiles(inputFilename, @"nfo")];
	} else {
		NSString *extension = [[inputFilename pathExtension] lowercaseString];
		//NSString *directory = [inputFilename stringByDeletingLastPathComponent];
		if ([extension isEqualToString:@"nfo"]) {
			[nfoFiles addObject:[@"" stringByAppendingPathComponent:inputFilename]];
			//							NSLog(@"m4vfile: %@", m4vFiles);
		}
	}
	
	// jpg
	if([[NSFileManager defaultManager] fileExistsAtPath:inputFilename isDirectory:&isDir] && isDir){
		//NSLog(@"Is directory");
		
		jpgFiles = [NSMutableArray arrayWithArray:getAllFiles(inputFilename, @"jpg")];
	} else {
		NSString *extension = [[inputFilename pathExtension] lowercaseString];
		//NSString *directory = [inputFilename stringByDeletingLastPathComponent];
		if ([extension isEqualToString:@"jpg"]) {
			[jpgFiles addObject:[@"" stringByAppendingPathComponent:inputFilename]];
			//							NSLog(@"m4vfile: %@", m4vFiles);
		}
	}
	
	// png
	if([[NSFileManager defaultManager] fileExistsAtPath:inputFilename isDirectory:&isDir] && isDir){
		//NSLog(@"Is directory");
		
		pngFiles = [NSMutableArray arrayWithArray:getAllFiles(inputFilename, @"png")];
	} else {
		NSString *extension = [[inputFilename pathExtension] lowercaseString];
		//NSString *directory = [inputFilename stringByDeletingLastPathComponent];
		if ([extension isEqualToString:@"png"]) {
			[pngFiles addObject:[@"" stringByAppendingPathComponent:inputFilename]];
			//							NSLog(@"m4vfile: %@", m4vFiles);
		}
	}
	
	int noOfFiles = (int)[nfoFiles count] + (int)[jpgFiles count] + (int)[pngFiles count];
	int fileCounter = 0;
	
	// Delete all files ...
	for (NSString *filePath in nfoFiles) {
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
		if (error != nil) {
			NSLog(@"Error: %@", error);
			NSLog(@"Path to file: %@", filePath);
		}
		//////////////////////
		// Display non verbose
		//
		if (!verbose) {
			NSString *displayString = [NSString stringWithFormat:@" %3i / %3lu", fileCounter, (unsigned long)noOfFiles];
			if (noOfFiles > 1) {
				progressBar(fileCounter, (int)noOfFiles, PROGRESSBAR_MAX_CALLS, PROGRESSBAR_WIDTH, displayString, @"");
			} else {
				progressBar(100, 100, PROGRESSBAR_MAX_CALLS, PROGRESSBAR_WIDTH, displayString, @"");
			}
		}
		fileCounter++;
	}
	
	for (NSString *filePath in jpgFiles) {
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
		if (error != nil) {
			NSLog(@"Error: %@", error);
			NSLog(@"Path to file: %@", filePath);
		}
		//////////////////////
		// Display non verbose
		//
		if (!verbose) {
			NSString *displayString = [NSString stringWithFormat:@" %3i / %3lu", fileCounter, (unsigned long)noOfFiles];
			if (noOfFiles > 1) {
				progressBar(fileCounter, (int)noOfFiles, PROGRESSBAR_MAX_CALLS, PROGRESSBAR_WIDTH, displayString, @"");
			} else {
				progressBar(100, 100, PROGRESSBAR_MAX_CALLS, PROGRESSBAR_WIDTH, displayString, @"");
			}
		}
		fileCounter++;
	}
	
	for (NSString *filePath in pngFiles) {
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
		if (error != nil) {
			NSLog(@"Error: %@", error);
			NSLog(@"Path to file: %@", filePath);
		}
		//////////////////////
		// Display non verbose
		//
		if (!verbose) {
			NSString *displayString = [NSString stringWithFormat:@" %3i / %3lu", fileCounter, (unsigned long)noOfFiles];
			if (noOfFiles > 1) {
				progressBar(fileCounter, (int)noOfFiles, PROGRESSBAR_MAX_CALLS, PROGRESSBAR_WIDTH, displayString, @"");
			} else {
				progressBar(100, 100, PROGRESSBAR_MAX_CALLS, PROGRESSBAR_WIDTH, displayString, @"");
			}
		}
		fileCounter++;
	}
	
}

void writeXML(Movie *currentMovie, NSString *filePath)
{
	NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"movie"];
	NSXMLDocument *xmlDoc = [NSXMLDocument documentWithRootElement:root];
	[xmlDoc setVersion:@"1.0"];
	[xmlDoc setCharacterEncoding:@"UTF-8"];
	[xmlDoc setStandalone:YES];
	
	//	[root addAttribute:[NSXMLNode attributeWithName:@"Attribute1" stringValue:@"Value1"]];
	//	[root addAttribute:[NSXMLNode attributeWithName:@"Attribute2" stringValue:@"Value2"]];
	//	[root addAttribute:[NSXMLNode attributeWithName:@"Attribute3" stringValue:@"Value3"]];
	
	
	//	NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
	
	//	[root addChild:[NSXMLNode commentWithStringValue:@"Hello world!"]];
	
	
	NSXMLElement *childElement = [[NSXMLElement alloc] initWithName:@"title" stringValue:currentMovie.title];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"originaltitle" stringValue:currentMovie.title];
	[root addChild:childElement];
	
	//	childElement = [[NSXMLElement alloc] initWithName:@"outline" stringValue:currentMovie.shortDescription];
	//	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"plot" stringValue:currentMovie.plot];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"mpaa" stringValue:currentMovie.mpaa];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"id" stringValue:currentMovie.imdbid];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"itunesid" stringValue:currentMovie.itunesid];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"storeid" stringValue:currentMovie.storeID];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"contentid" stringValue: [NSString stringWithFormat:@"%li", (long)currentMovie.contentID]];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"rating" stringValue:currentMovie.rating];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"year" stringValue:currentMovie.year];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"top250" stringValue:currentMovie.top250];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"votes" stringValue:currentMovie.votes];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"outline" stringValue:currentMovie.outline];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"tagline" stringValue:currentMovie.tagline];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"runtime" stringValue:currentMovie.runtime];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"playcount" stringValue:currentMovie.playcount];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"lastplayed" stringValue:currentMovie.lastplayed];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"set" stringValue:currentMovie.set];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"premiered" stringValue:currentMovie.premiered];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"status" stringValue:currentMovie.status];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"code" stringValue:currentMovie.code];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"aired" stringValue:currentMovie.aired];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"dateadded" stringValue:currentMovie.dateadded];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"copyright" stringValue:currentMovie.copyright];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"trailer" stringValue:currentMovie.trailer];
	[root addChild:childElement];
	
	if (currentMovie.kind == MP4MediaTypeMovie) {
		childElement = [[NSXMLElement alloc] initWithName:@"kind" stringValue:@"feature-movie"];
		[root addChild:childElement];
	} else if (currentMovie.kind == MP4MediaTypeTvShow) {
		childElement = [[NSXMLElement alloc] initWithName:@"kind" stringValue:@"feature-???"];
		[root addChild:childElement];
	}
	
	childElement = [[NSXMLElement alloc] initWithName:@"artistname" stringValue:currentMovie.artistname];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"releasedate" stringValue:currentMovie.releasedate];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"studio" stringValue:currentMovie.studio];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"mpaaitunes" stringValue:currentMovie.mpaaiTunes];
	[root addChild:childElement];
	
	childElement = [[NSXMLElement alloc] initWithName:@"contentadvisoryrating" stringValue:currentMovie.contentAdvisoryRating];
	[root addChild:childElement];
	
	// Genres
	for (NSString *genre in currentMovie.genres) {
		childElement = [[NSXMLElement alloc] initWithName:@"genre" stringValue:genre];
		[root addChild:childElement];
	}
	
	// country
	for (NSString *country in currentMovie.countries) {
		childElement = [[NSXMLElement alloc] initWithName:@"country" stringValue:country];
		[root addChild:childElement];
	}
	
	// Credits
	for (Actor *producer in currentMovie.producers) {
		childElement = [[NSXMLElement alloc] initWithName:@"credits" stringValue:producer.name];
		[root addChild:childElement];
	}
	
	// Directors
	for (Actor *director in currentMovie.directors) {
		childElement = [[NSXMLElement alloc] initWithName:@"director" stringValue:director.name];
		[root addChild:childElement];
	}
	
	// Thumbs
	for (Thumb *thumb in currentMovie.thumbs) {
		childElement = [[NSXMLElement alloc] initWithName:@"thumb" stringValue:thumb.value];
		
		if (![thumb.aspect isEqualToString:@""]) {
			[childElement addAttribute:[NSXMLNode attributeWithName:@"aspect" stringValue:thumb.aspect]];
		}
		if (![thumb.preview isEqualToString:@""]) {
			[childElement addAttribute:[NSXMLNode attributeWithName:@"preview" stringValue:thumb.preview]];
		}
		[root addChild:childElement];
	}
	
	// Fanarts
	if ([currentMovie.fanarts count] > 0) {
		childElement = [[NSXMLElement alloc] initWithName:@"fanart"];
		
		for (Thumb *thumb in currentMovie.fanarts) {
			
			NSXMLElement *nameElement = [[NSXMLElement alloc] initWithName:@"thumb" stringValue:thumb.value];
			
			if (![thumb.aspect isEqualToString:@""]) {
				[nameElement addAttribute:[NSXMLNode attributeWithName:@"aspect" stringValue:thumb.aspect]];
			}
			if (![thumb.preview isEqualToString:@""]) {
				[nameElement addAttribute:[NSXMLNode attributeWithName:@"preview" stringValue:thumb.preview]];
			}
			[childElement addChild:nameElement];
			
		}
		[root addChild:childElement];
	}
	
	
	// Actors
	for (Actor *actor in currentMovie.actors) {
		childElement = [[NSXMLElement alloc] initWithName:@"actor"];
		
		NSXMLElement *nameElement = [[NSXMLElement alloc] initWithName:@"name" stringValue:actor.name];
		[childElement addChild:nameElement];
		
		NSXMLElement *roleElement = [[NSXMLElement alloc] initWithName:@"role" stringValue:actor.role];
		[childElement addChild:roleElement];
		
		NSXMLElement *orderElement = [[NSXMLElement alloc] initWithName:@"order" stringValue:actor.order];
		[childElement addChild:orderElement];
		
		NSXMLElement *thumbElement = [[NSXMLElement alloc] initWithName:@"thumb" stringValue:actor.thumb];
		[childElement addChild:thumbElement];
		
		[root addChild:childElement];
	}
	
	//	NSXMLElement *childElement2 = [[NSXMLElement alloc] initWithName:@"ChildElement2"];
	//	[childElement2 addAttribute:[NSXMLNode attributeWithName:@"ChildAttribute2.1" stringValue:@"Value2.1"]];
	//	[childElement2 setStringValue:@"ChildValue2.1"];
	//	[root addChild:childElement2];
	
	
	
	
	//	NSLog(@"XML Document\n%@", xmlDoc);//till this art code runs fine.
	NSData *xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
	
	[[NSFileManager defaultManager] createFileAtPath:filePath contents:xmlData attributes:nil];
	
	//	file = [NSFileHandle fileHandleForUpdatingAtPath: filePath];
	//	//set writing path to file
	//	if (file == nil) //check file present or not in file
	//		NSLog(@"Failed to open file");
	//	//[file seekToFileOffset: 6];
	//	//object pointer initialy points the offset as 6 position in file
	//	[file writeData: xmlData];
	//	//writing data to new file
	//	[file closeFile];
	
	//	[xmlData writeToFile:@"/Users/halen/Documents/project3/xmlsample.xml" atomically:YES];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Main
//
int main(int argc, const char * argv[]) {
	@autoreleasepool {
		// insert code here...
		//printf("scraper v %.1f\n", APPVERSION);
		
		NSString		*inputFilename	= NULL;
		NSString		*nfoFilename	= NULL;
		NSString		*pngFilename	= NULL;
		NSString		*inputFullname	= NULL;
		NSString		*inputDir		= NULL;
		NSString		*inputParentDir	= NULL;
		NSString		*inputTitle		= NULL;
		NSString		*inputCC		= @"de";
		
		NSString		*artworkFilename	= NULL;
		NSString		*fanartFilename		= NULL;
		
		NSNumber		*inputLimit		=	@1;
		int				fileCounter		=	1;
		
		NSMutableArray	*m4vFiles = [[NSMutableArray alloc] init];
		
		BOOL			ignoreNFO		= false;
		
		BOOL			writenfo		= false;
		BOOL			overwritenfo	= false;
		BOOL			nolookup		= false;
		BOOL			unattended		= false;
		BOOL			skip			= false;
		BOOL			listmetadata	= false;
		BOOL			ignoreTags		= false;
		BOOL			tag				= false;
		BOOL			hasArtwork		= false;
		BOOL			extract			= false;
		
		NSUInteger		noOfFiles		= 1;
		
		NSInteger		curRating		= 0;
		
		NSMutableArray *skippedMovies	= [[NSMutableArray alloc] init];
		NSMutableArray *processedMovies	= [[NSMutableArray alloc] init];
		
		NSFileManager *fileManager		= [NSFileManager defaultManager];
		
		xmlParser = [[XMLParser alloc] init];
		
		printf(" \n");
		printf("     _______ _______  ______ _______  _____  _______  ______	\n");
		printf("     |______ |       |_____/ |_____| |_____] |______ |_____/	\n");
		printf("     ______| |_____  |    \\_ |     | |       |______ |    \\_	\n");
		printf("\n");
		printf("This Software is currently in Beta status. Backup your files!	\n");
		printf("\n");
		printf("\n");
		
		if (argc == 1) {
			print_help();
			exit(-1);
		}
		
		argv += 1;
		argc--;
#ifdef DEBUG
		printf("DEBUG MODE enabled!\n");
		printf("DEBUG - Parameter: \n");
#endif
		
		// Handle args
		while (argc > 0 && **argv == '-') {
			const char *args = &(*argv)[1];
			
			argc--;
			argv++;

#ifdef DEBUG
			printf("-%s ",args);
			fflush(stdout);
#endif
			
			if (( ! strcmp ( args, "input" )) || ( ! strcmp ( args, "i" )) ) {
				inputFilename = @(*argv++);
				argc--;
#ifdef DEBUG
				printf("%s ",[inputFilename UTF8String]);
				fflush(stdout);
#endif
				
				BOOL isDir = NO;
				if([[NSFileManager defaultManager] fileExistsAtPath:inputFilename isDirectory:&isDir] && isDir){
					//NSLog(@"Is directory");
					//inputDir = [inputFilename stringByDeletingLastPathComponent];
					inputDir = inputFilename;
					// if inputDir does NOT end inputFilename with "/" add it
					if (![inputDir hasSuffix:@"/"]){
						inputDir = [NSString stringWithFormat:@"%@/", inputDir];
					}
					
					m4vFiles = [NSMutableArray arrayWithArray:getAllFiles(inputDir, @"m4v")];
				} else {
					inputDir = [inputFilename stringByDeletingLastPathComponent];
					NSString *extension = [[inputFilename pathExtension] lowercaseString];
					//NSString *directory = [inputFilename stringByDeletingLastPathComponent];
					if ([extension isEqualToString:@"m4v"]) {
						[m4vFiles addObject:[@"" stringByAppendingPathComponent:inputFilename]];
						//							NSLog(@"m4vfile: %@", m4vFiles);
					}
				}
				noOfFiles = [m4vFiles count];
			}
			else if (( ! strcmp ( args, "verbose" )) || ( ! strcmp ( args, "v" )) ) {
				verbose = YES;
			}
			else if (( ! strcmp ( args, "nfo" )) || ( ! strcmp ( args, "n" )) ) {
				nfoFilename = @(*argv++);
				argc--;
#ifdef DEBUG
				printf("%s ",[nfoFilename UTF8String]);
				fflush(stdout);
#endif
				if (verbose) {
					
				}
			}
			else if (( ! strcmp ( args, "title" )) || ( ! strcmp ( args, "T" )) ) {
				inputTitle = @(*argv++);
#ifdef DEBUG
				printf("%s ",[inputTitle UTF8String]);
				fflush(stdout);
#endif
				argc--;
			}
			else if (( ! strcmp ( args, "limit" )) || ( ! strcmp ( args, "L" )) ) {
				
				NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
				[f setNumberStyle:NSNumberFormatterDecimalStyle];
				inputLimit = [f numberFromString:@(*argv++)];
				argc--;
#ifdef DEBUG
				printf("%ld ",[inputLimit longValue]);
				fflush(stdout);
#endif
			}
			else if (( ! strcmp ( args, "country" )) || ( ! strcmp ( args, "c" )) ) {
				inputCC = @(*argv++);
				argc--;
#ifdef DEBUG
				printf("%s ",[inputCC UTF8String]);
				fflush(stdout);
#endif
			}
			else if (( ! strcmp ( args, "extract" )) || ( ! strcmp ( args, "e" )) ) {
				pngFilename = @(*argv++);
				argc--;
#ifdef DEBUG
				printf("%s ",[pngFilename UTF8String]);
				fflush(stdout);
#endif
			}
			else if (( ! strcmp ( args, "extractdefault" )) || ( ! strcmp ( args, "ed" )) ) {
				extract = YES;
			}
			else if (( ! strcmp ( args, "listcc" )) || ( ! strcmp ( args, "C" )) ) {
				print_cc();
				return 0;
			}
			else if (( ! strcmp ( args, "remove" )) || ( ! strcmp ( args, "r" )) ) {
				removeData(inputFilename);
				return 0;
			}
			else if (( ! strcmp ( args, "listmetadata" )) || ( ! strcmp ( args, "lm" )) ) {
				listmetadata = YES;
			}
			else if (( ! strcmp ( args, "ignoretags" )) || ( ! strcmp ( args, "it" )) ) {
				ignoreTags = YES;
			}
			else if (( ! strcmp ( args, "nolookup" )) || ( ! strcmp ( args, "N" )) ) {
				nolookup = YES;
			}
			else if (( ! strcmp ( args, "unattended" )) || ( ! strcmp ( args, "u" )) ) {
				unattended = YES;
			}
			else if (( ! strcmp ( args, "tag" )) || ( ! strcmp ( args, "t" )) ) {
				tag = YES;
			}
			else if (( ! strcmp ( args, "ignorenfo" )) || ( ! strcmp ( args, "I" )) ) {
				ignoreNFO = YES;
			}
			else if (( ! strcmp ( args, "writenfo" )) || ( ! strcmp ( args, "w" )) ) {
				writenfo = YES;
			}
			else if (( ! strcmp ( args, "overwritenfo" )) || ( ! strcmp ( args, "O" )) ) {
				overwritenfo = YES;
			}
			else if (( ! strcmp ( args, "version" )) || ( ! strcmp ( args, "V" )) ) {
				print_version();
				return 0;
			}
			else if (( ! strcmp ( args, "workflow" )) || ( ! strcmp ( args, "W" )) ) {
				print_workflow();
				return 0;
			}
			else if (( ! strcmp ( args, "help" )) || ( ! strcmp ( args, "h" )) ) {
				print_help();
				return 0;
			} else {
				printf("Invalid input parameter: %s\n", args );
				print_help();
				return 1;
			}
		}
#ifdef DEBUG
		printf("\n");
#endif
		
		//		printf("Searching Movie for movie: ");
		//		fflush(stdout);
		//
		//		for (int i=1; i<=100; i++) {
		//			progressBar(i, 100, PROGRESSBAR_MAX_CALLS, PROGRESSBAR_WIDTH, @"Searching Movie for movie ");
		//			usleep(10000);
		//		}
		
		
		
		// Override Limit when unattended
		if (unattended) {
			inputLimit = @1;
		}
		
		if (verbose) {
			printf("Parameter: \n");
			printf("\t verbose:   \t %hhd\n", verbose);
			printf("\t inputCC:   \t %s\n", [inputCC UTF8String]);
			
			if (ignoreNFO) {
				printf("\t ignorenfo:   \t %hhd\n", ignoreNFO);
			}
			if (nfoFilename != NULL) {
				printf("\t nfo:   \t %s\n", [nfoFilename UTF8String]);
			}
			if (inputTitle != NULL) {
				printf("\t title:   \t %s\n", [inputTitle UTF8String]);
			}
			if (writenfo) {
				printf("\t writenfo:	\t %hhd\n", writenfo);
			}
			if (overwritenfo) {
				printf("\t overwritenfo:   \t %hhd\n", overwritenfo);
			}
			
			printf("\t No Files:   \t %lu\n", (unsigned long)noOfFiles);
			for (int i=0; i<noOfFiles; i++) {
				printf("\t input:   \t %s\n", [[m4vFiles objectAtIndex:i] UTF8String]);
				//				NSLog(@"%@",[m4vFiles objectAtIndex:i]);
			}
			
			
		}
		
		//NSLog(@"m4vFiles: %@",m4vFiles);
		Movie *currentMovie;
		MP42File *mp4File = nil;
		
		for (NSString *m4vFile in m4vFiles) {
			currentMovie = [[Movie alloc] init];
			
			inputFullname =  [NSString stringWithFormat:@"%s",[m4vFile UTF8String]];
			
			// Trim inputFullname
			inputFullname = [inputFullname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			inputDir = [inputFullname stringByDeletingLastPathComponent];
			// documentDirectory = @"~me/Public/Demo"
			
			//NSString *documentFilename = [fileURL lastPathComponent];
			// documentFilename = @"readme.txt"
			
			//NSString *fileExtension = [fileURL pathExtension];
			// documentExtension = @"txt"
			
			NSArray *components = [inputFullname pathComponents];
			inputParentDir = [NSString pathWithComponents:[components subarrayWithRange:(NSRange){ [components count] - 2 , 1}]];
			
			NSString* fileName = [[inputFullname lastPathComponent] stringByDeletingPathExtension];
			
			if(!unattended) {
				printf("================== %s ==================\n", [fileName UTF8String]);
			}
			
			nfoFilename = [NSString stringWithFormat:@"%@/%@.nfo", inputDir, fileName];
			NSString *nfoFilename2 = [NSString stringWithFormat:@"%@/movie.nfo", inputDir];
			

			
			NSString *nfoTarget = nfoFilename;
			//			if (verbose) {
			//				printf("\t input:		\t %s\n", [inputFullname UTF8String]);
			//				printf("\t Dir name:	\t %s\n", [inputParentDir UTF8String]);
			//				printf("\t File name:	\t %s\n", [fileName UTF8String]);
			//				printf("\t nfo file:	\t %s\n", [nfoFilename UTF8String]);
			//			}
			
			
			//////////////////////
			// Read Tags
			//
			//mp4File = [[MP42File alloc] initWithExistingFile:[NSURL fileURLWithPath:inputFullname] andDelegate:nil];
			if ([[NSFileManager defaultManager] fileExistsAtPath:inputFullname]) {
				mp4File = [[MP42File alloc] initWithExistingFile:[NSURL fileURLWithPath:inputFullname]
													 andDelegate:nil];
			}
			
			if (!mp4File) {
				if (!unattended) {
					printf("Error: %s\n", "the mp4 file couln't be opened.");
					return -1;
				}
				[skippedMovies addObject:currentMovie];
				skip=YES;
			}
			if ((!ignoreTags) || (listmetadata)) {
				if (!unattended) {
					printf("Reading tags...");
				}
				
				NSArray * availableMetadata = [[mp4File metadata] availableMetadata];
				NSDictionary * tagsDict = [[mp4File metadata] tagsDict];
				
				if (!unattended) {
					printf(" OK\n");
				}
				
				for (NSString* key in availableMetadata) {
					NSString* tag = [tagsDict valueForKey:key];
					if (tag) {
						if ([tag isKindOfClass:[NSString class]]) {
							if ((verbose) || (listmetadata)) {
								printf("%s: %s\n", [key UTF8String], [tag UTF8String]);
							}
						}
						if ([tag isKindOfClass:[NSNumber class]]) {
							if ((verbose) || (listmetadata)) {
								printf("%s: %ld\n", [key UTF8String], (long)[tag integerValue]);
							}
						}
						if ([key isEqualToString:@"Name"])
							currentMovie.title = tag;
						
						if ([key isEqualToString:@"Artist"])
							currentMovie.artistname = tag;
						
						if ([key isEqualToString:@"Rating"])
							curRating = [tag integerValue];
						
						if ([key isEqualToString:@"Genre"]) {
							NSMutableArray *curGenres = [[NSMutableArray alloc] init];
							[curGenres addObject:tag];
							currentMovie.genres = curGenres;
						}
						
						if ([key isEqualToString:@"Release Date"]) {
							currentMovie.releasedate = tag;
							currentMovie.year = [currentMovie.releasedate substringWithRange: NSMakeRange (0, 4)];
							
						}
						
						if ([key isEqualToString:@"iTunes Country"])
							currentMovie.storeID = tag;
						
						if ([key isEqualToString:@"Description"])
							currentMovie.plot = tag;
						
						if ([key isEqualToString:@"Copyright"])
							currentMovie.copyright = tag;
						
						if ([key isEqualToString:@"contentID"])
							currentMovie.contentID = (long)[tag integerValue];
						
						if ([key isEqualToString:@"Cast"]) {
							//NSLog(@"%@",tag);
							NSArray *tempArray = [[NSArray alloc]init];
							NSMutableArray *actors = [[NSMutableArray alloc] init];
							tempArray = [tag componentsSeparatedByString:@","];
							
							for	(NSString *curActor in tempArray) {
								Actor *newActor = [[Actor alloc] initWithName:curActor];
								[actors addObject:newActor];
							}
							currentMovie.actors = actors;
						}
						
						if ([key isEqualToString:@"Director"]) {
							//NSLog(@"%@",tag);
							NSArray *tempArray = [[NSArray alloc]init];
							NSMutableArray *actors = [[NSMutableArray alloc] init];
							tempArray = [tag componentsSeparatedByString:@","];
							
							for	(NSString *curActor in tempArray) {
								Actor *newActor = [[Actor alloc] initWithName:curActor];
								[actors addObject:newActor];
							}
							currentMovie.directors = actors;
						}
						
						if ([key isEqualToString:@"Producers"]) {
							//NSLog(@"%@",tag);
							NSArray *tempArray = [[NSArray alloc]init];
							NSMutableArray *actors = [[NSMutableArray alloc] init];
							tempArray = [tag componentsSeparatedByString:@","];
							
							for	(NSString *curActor in tempArray) {
								Actor *newActor = [[Actor alloc] initWithName:curActor];
								[actors addObject:newActor];
							}
							currentMovie.producers = actors;
						}
						
						
					}
					
					
				}
				
				if ([[mp4File metadata] hdVideo]) {
					if ((verbose) || (listmetadata))
						printf("HD Video: %d\n", [[mp4File metadata] hdVideo]);

					currentMovie.hd = [[mp4File metadata] hdVideo];
				}
				if ([[mp4File metadata] gapless]) {
					if ((verbose) || (listmetadata))
						printf("Gapless: %d\n", [[mp4File metadata] gapless]);
				}
				if ([[mp4File metadata] contentRating]) {
					if ((!ignoreTags) || (listmetadata))
						printf("Content Rating: %d\n", [[mp4File metadata] contentRating]);
					
					//currentMovie.contentAdvisoryRating = [[mp4File metadata] contentRating];
				}
				
				if ([[mp4File metadata] podcast]) {
					if ((verbose) || (listmetadata))
						printf("Podcast: %d\n", [[mp4File metadata] podcast]);
				}
				if ([[mp4File metadata] mediaKind]) {
					if ((verbose) || (listmetadata))
						printf("Media Kind: %d\n", [[mp4File metadata] mediaKind]);

					MP4MediaType kind;
					if ([[mp4File metadata] mediaKind] == 9) {
						kind = MP4MediaTypeMovie;
					}
					
					if ([[mp4File metadata] mediaKind] == 10) {
						kind = MP4MediaTypeTvShow;
					}
					currentMovie.kind = kind;
				}
				
				if ([[[mp4File metadata] artworks] count]) {
					currentMovie.artworks = [NSArray arrayWithArray:[[mp4File metadata] artworks]];
				}
			}
			
			//////////////////////
			// Save Artwork to File System as <pngFilename>
			//
			
			if (pngFilename != nil) {
				if (currentMovie.artwork != nil) {
					if (!unattended) {
						printf("Extracting artwork...");
					}
					//NSBitmapImageRep *imgRep = [[currentMovie.artwork representations] objectAtIndex: 0];
					//NSData *data = [imgRep representationUsingType: NSPNGFileType properties: nil];
					//[data writeToFile: pngFilename atomically: NO];
					
					for (MP42Image *curArtwork in currentMovie.artworks) {
						[curArtwork.data writeToFile: pngFilename atomically: NO];
					}
					
					
					if (!unattended) {
						printf(" OK\n");
						
					}
				}
			}
			
			
			//////////////////////
			// Save Artwork to File System as <movie name>-poster.png
			//
			if (extract) {
				if (!unattended) {
					printf("Extracting artwork...");
				}
				
				NSString *artworkFilename = nil;

				int prevType = 0;
				int curCounter = 1;
				
				int artworkCounter = 0;
				for (MP42Image *curArtwork in currentMovie.artworks) {
					

					NSArray * imageReps = [NSBitmapImageRep imageRepsWithData:curArtwork.data];
					
					NSInteger width = 0;
					NSInteger height = 0;
					
					int curType = 0;
					
					NSString *artworkType = nil;
					
					for (NSImageRep * imageRep in imageReps) {
						if ([imageRep pixelsWide] > width) width = [imageRep pixelsWide];
						if ([imageRep pixelsHigh] > height) height = [imageRep pixelsHigh];
					}
					
					
					CGFloat wFloat = [[NSNumber numberWithInteger:width] floatValue];
					CGFloat hFloat = [[NSNumber numberWithInteger: height] floatValue];
					CGFloat aspRatio = (wFloat / hFloat);
					
					
					// Poster: 800 x 1200
					// Aspect: 0.666
					//
					if ((aspRatio > 0.6) && (aspRatio < 0.7)) {
						artworkType = @"poster";
						curType = 1;
					}
					
					// Banner: 758 x 140
					// Aspect: 5.414
					else if ((aspRatio > 5.3) && (aspRatio < 5.5)) {
						artworkType = @"banner";
						curType = 2;
					}
					
					// Sqaure: 758 x 140
					// Aspect: 1.0
					else if ((aspRatio > 0.9) && (aspRatio < 1.1)) {
						artworkType = @"square";
						curType = 3;
					}
					
					// Fanart: 720p
					else if ((width == 1280) && (height == 720)) {
						artworkType = @"fanart";
						curType = 4;
					}
					
					// Fanart: 1080p
					else if ((width == 1920) && (height == 1080)) {
						artworkType = @"fanart";
						curType = 4;
					}
					
					
					if (artworkCounter == 0) {
						artworkFilename = [NSString stringWithFormat:@"%@/%@-%@.png", inputDir, fileName, artworkType];
					} else {
						if (prevType == curType) {
							artworkFilename = [NSString stringWithFormat:@"%@/%@-%@-%d.png", inputDir, fileName, artworkType, curCounter];
							curCounter++;
						} else {
							artworkFilename = [NSString stringWithFormat:@"%@/%@-%@.png", inputDir, fileName, artworkType];
							curCounter=1;
						}
					}
					
					[curArtwork.data writeToFile: artworkFilename atomically: NO];
					artworkCounter++;
					prevType = curType;
				}
				if (!unattended) {
					printf(" OK\n");
					
				}
			}
			
			
			//////////////////////
			// EXIT if listmetadata !!!
			//
			if (listmetadata) {
				printf("Exiting! Tags are listed above!\n");
				return 0;
			}
			
			//////////////////////
			// Read nfo file
			//
			if (!ignoreNFO) {
				
				NSString *result = nil;

				
				if (!unattended) {
					printf("Reading nfo: ");
				}
				
				if ([fileManager fileExistsAtPath:nfoFilename]){
					xmlParser = [[XMLParser alloc] init ];
					if (verbose) {
						printf("%s ...", [nfoFilename UTF8String]);
						fflush(stdout);
					}
					currentMovie = [xmlParser loadXMLByPath:nfoFilename];
					//					NSLog(@"currentMovie: %@",currentMovie);
					
					if (verbose) {
						printf(" OK\n");
					}
				} else if ([fileManager fileExistsAtPath:nfoFilename2]){
					//xmlParser = [[XMLParser alloc] loadXMLByPath:nfoFilename2];
					//currentMovie = [[xmlParser movies] objectAtIndex:0];
					xmlParser = [[XMLParser alloc] init ];
					if (verbose) {
						printf("%s ...", [nfoFilename UTF8String]);
						fflush(stdout);
					}
					nfoFilename = nfoFilename2;
					currentMovie = [xmlParser loadXMLByPath:nfoFilename];
					//					NSLog(@"currentMovie: %@",currentMovie);
					
					if (verbose) {
						printf(" OK\n");
					}
					
				} else {
					result = @"File not Found";
				}
				
				if (!unattended) {
					
						if (result == nil) {
							printf(" OK \n");
						} else {
							printf(" File not Found\n");
						}
				}
			}
			
			
			
			
			
			//////////////////////
			// Set Title
			//
			// Set Title from Folder if not specified in nfo file
			if (inputTitle == NULL) {
				if ([currentMovie.title isEqualToString:@""]){
					currentMovie.title = fileName;
				}
			} else {
				currentMovie.title = inputTitle;
			}
			// Replace "_" with " "
			currentMovie.title = [currentMovie.title stringByReplacingOccurrencesOfString:@"_" withString:@" "];
			// Replace " (HD)" with ""
			currentMovie.title = [currentMovie.title stringByReplacingOccurrencesOfString:@" (HD)" withString:@""];
			// Replace " (1080p HD)" with ""
			currentMovie.title = [currentMovie.title stringByReplacingOccurrencesOfString:@" (1080p HD)" withString:@""];
			currentMovie.title = [currentMovie.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			
			//////////////////////
			//  iTunes Lookup
			//
			if (!nolookup) {
				
				if (!unattended) {
					
						printf("Search for movie...\n");
					
				}
				
				iTunesAPI *itunesapi =  [[iTunesAPI alloc] init];
				
				//////////////////////
				// Get storeID by c parameter
				//
				currentMovie.storeID = [[itunesapi iTunesStoreCodes] valueForKey:inputCC];
				
				NSString* searchTitleEncodedUrl = [currentMovie.title stringByAddingPercentEscapesUsingEncoding:
												   NSUTF8StringEncoding];
				
				NSDictionary *searchResults = [itunesapi searchForTitle:searchTitleEncodedUrl inCountry:inputCC withLimit:[inputLimit stringValue]];
				
				NSString *oldTitle = currentMovie.title;
				
				if ([[searchResults valueForKeyPath:@"results"] count] == 0) {
					
					
					NSRange range = [currentMovie.title rangeOfString:@" - "];
					if ( range.length > 0 ) {
						
						currentMovie.title = [currentMovie.title substringToIndex:range.location];
						searchTitleEncodedUrl = [currentMovie.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
						
						searchResults = [itunesapi searchForTitle:searchTitleEncodedUrl inCountry:inputCC withLimit:[inputLimit stringValue]];
					}
					
					if ([[searchResults valueForKeyPath:@"results"] count] == 0) {
						range = [currentMovie.title rangeOfString:@":"];
						if ( range.length > 0 ) {
							
							currentMovie.title = [currentMovie.title substringToIndex:range.location];
							searchTitleEncodedUrl = [currentMovie.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
							
							searchResults = [itunesapi searchForTitle:searchTitleEncodedUrl inCountry:inputCC withLimit:[inputLimit stringValue]];
						}
					}
					
					if ([[searchResults valueForKeyPath:@"results"] count] == 0) {
						searchTitleEncodedUrl = [currentMovie.originaltitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
						searchResults = [itunesapi searchForTitle:searchTitleEncodedUrl inCountry:inputCC withLimit:[inputLimit stringValue]];
					}
					
					if (!unattended) {
						if ([[searchResults valueForKeyPath:@"results"] count] == 0) {
							
							printf("Please enter the movie title manually: ");
							char cstring[100];
							scanf("%s", cstring);
							
							NSString *manualTitle = [NSString stringWithCString:cstring encoding:1];
							searchTitleEncodedUrl = [manualTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
							searchResults = [itunesapi searchForTitle:searchTitleEncodedUrl inCountry:inputCC withLimit:@"1"];
						}
					} else {
						skip = YES;
						currentMovie.title = oldTitle;
						[skippedMovies addObject:currentMovie];
					}
				}
				
				
				if (!skip) {
					if ([[searchResults valueForKeyPath:@"results"] count] > 1) {
						
						//printf("%s (%s) - %i \n", [trackName UTF8String],[year UTF8String],[trackID intValue]);
						printf("[0] Cancel \n");
						
						for (int i=0; i<[[searchResults valueForKeyPath:@"results"] count]; i++) {
							//			NSLog(@"trackID: %@", [[searchResults valueForKeyPath:@"results.trackId"] objectAtIndex:i]);
							//			NSLog(@"trackName: %@", [[searchResults valueForKeyPath:@"results.trackName"] objectAtIndex:i]);
							//			NSLog(@"trackYear: %@", [[searchResults valueForKeyPath:@"results.releaseDate"] objectAtIndex:i]);
							//			NSLog(@"trackViewUrl: %@", [[searchResults valueForKeyPath:@"results.trackViewUrl"] objectAtIndex:i]);
							
							
							NSString *trackName = [[searchResults valueForKeyPath:@"results.trackName"] objectAtIndex:i];
							NSString *releaseDate = [[searchResults valueForKeyPath:@"results.releaseDate"] objectAtIndex:i];
							//NSNumber *trackID = [[searchResults valueForKeyPath:@"results.trackId"] objectAtIndex:i];
							
							
							NSRange needleRange = NSMakeRange(0,4);
							NSString *year = [releaseDate substringWithRange:needleRange];
							
							printf("[%i] ", i+1);
							//printf("%s (%s) - %i \n", [trackName UTF8String],[year UTF8String],[trackID intValue]);
							printf("%s (%s) \n", [trackName UTF8String],[year UTF8String]);
							
							
						}
					}
					int n;
					if ([[searchResults valueForKeyPath:@"results"] count] > 1) {
						
						printf("Please enter the number: ");
						scanf("%i", &n);
						
						printf("Selected Option: %i \n", n);
						if (n == 0) {
							skip = YES;
							[skippedMovies addObject:currentMovie];
						}
					} else {
						n=1;
					}
					
					if (!skip) {
						if (verbose) {
							printf("Looking up for %s...",[[[searchResults valueForKeyPath:@"results.trackName"] objectAtIndex:n-1] UTF8String]);
						}
						
						if (!unattended) {
								printf("Looking up for %s...",[[[searchResults valueForKeyPath:@"results.trackName"] objectAtIndex:n-1] UTF8String]);
						
						}
						
						NSString *tempString;
						
						tempString = [[searchResults valueForKeyPath:@"results.trackName"] objectAtIndex:n-1];
						if (tempString != NULL) {
							currentMovie.title = tempString;
						}
						
						tempString = [[searchResults valueForKeyPath:@"results.trackName"] objectAtIndex:n-1];
						if (tempString != NULL) {
							currentMovie.originaltitle = tempString;
						}
						
						tempString = [[[searchResults valueForKeyPath:@"results.trackId"] objectAtIndex:n-1] stringValue];
						if (tempString != NULL) {
							currentMovie.itunesid = tempString;
							currentMovie.contentID = [tempString integerValue];
						}
						
						tempString = [[searchResults valueForKeyPath:@"results.releaseDate"] objectAtIndex:n-1];
						if (tempString != NULL) {
							
							
							NSRange needleRange = NSMakeRange(0,4);
							NSString *year = [tempString substringWithRange:needleRange];
							currentMovie.year = year;
							
							needleRange = NSMakeRange(0,10);
							NSString *rd = [tempString substringWithRange:needleRange];
							currentMovie.releasedate = rd;
						}
						
						tempString = [[searchResults valueForKeyPath:@"results.artistName"] objectAtIndex:n-1];
						if (tempString != NULL) {
							currentMovie.artistname = tempString;
						}
						
						tempString = [[searchResults valueForKeyPath:@"results.kind"] objectAtIndex:n-1];
						if ([tempString isEqualToString:@"feature-movie"]) {
							currentMovie.kind = MP4MediaTypeMovie;
						}
						
						tempString = [[searchResults valueForKeyPath:@"results.longDescription"] objectAtIndex:n-1];
						if (tempString != NULL) {
							currentMovie.plot = tempString;
						}
						
						tempString = [[searchResults valueForKeyPath:@"results.contentAdvisoryRating"] objectAtIndex:n-1];
						if (tempString != NULL) {
							currentMovie.mpaa = [itunesapi getMPAARatingString:tempString];
							currentMovie.mpaaiTunes = tempString;
							currentMovie.contentAdvisoryRating = [itunesapi getiTunesRatingString:tempString];
						}
						
						tempString = [[searchResults valueForKeyPath:@"results.primaryGenreName"] objectAtIndex:n-1];
						if (tempString != NULL) {
							[currentMovie.genres arrayByAddingObject:tempString];
						}
						
						NSString *artworkUrl = [itunesapi getHighResArtworkUrl:[[searchResults valueForKeyPath:@"results.artworkUrl100"] objectAtIndex:n-1]];
						
						
						//////////////////////
						// Thumbs
						//
						NSMutableArray* curThumbs = [[NSMutableArray alloc] init];
						if ([currentMovie.thumbs count] > 0) {
							
							
							for (Thumb *thumb in currentMovie.thumbs) {
								[curThumbs addObject:thumb];
							}
						}
						Thumb *curThumb = [[Thumb alloc] init];
						curThumb.aspect = @"poster";
						curThumb.preview = @"";
						curThumb.value = artworkUrl;
						
						[curThumbs addObject:curThumb];
						currentMovie.thumbs = curThumbs;
						
						//////////////////////
						// Cast & Crew
						//
						
						NSMutableDictionary *castResult = [[NSMutableDictionary alloc] init];
						castResult = [NSMutableDictionary dictionaryWithDictionary:[itunesapi lookupCast:[[searchResults valueForKeyPath:@"results.trackViewUrl"] objectAtIndex:n-1]]];
						
						// Actors
						if ([currentMovie.actors count] == 0) {
							
							NSArray *curActors = [NSArray arrayWithArray:[castResult objectForKey:@"actors"]];
							NSMutableArray *actors = [[NSMutableArray alloc] init];
							
							for (NSString *curActor in curActors) {
								Actor *newActor = [[Actor alloc] initWithName:curActor];
								
								[actors addObject:newActor];
							}
							currentMovie.actors = actors;
						}
						
						// directors
						if ([currentMovie.directors count] == 0) {
							
							NSArray *curDirectors = [NSArray arrayWithArray:[castResult objectForKey:@"directors"]];
							NSMutableArray *directors = [[NSMutableArray alloc] init];
							
							for (NSString *curActor in curDirectors) {
								Actor *newActor = [[Actor alloc] initWithName:curActor];
								
								[directors addObject:newActor];
							}
							currentMovie.directors = directors;
						}
						
						// producers
						if ([currentMovie.producers count] == 0) {
							
							NSArray *curProducers = [NSArray arrayWithArray:[castResult objectForKey:@"producers"]];
							NSMutableArray *producers = [[NSMutableArray alloc] init];
							
							for (NSString *curActor in curProducers) {
								Actor *newActor = [[Actor alloc] initWithName:curActor];
								
								[producers addObject:newActor];
							}
							currentMovie.producers = producers;
						}
						
						// copyright
						if ([[castResult objectForKey:@"copyrights"] count] > 0) {
							
							NSString *tempString = [[NSArray arrayWithArray:[castResult objectForKey:@"copyrights"]] objectAtIndex:0];
							[tempString stringByReplacingOccurrencesOfString:@" All Rights Reserved." withString:@""];
							[tempString stringByReplacingOccurrencesOfString:@" All Rights Reserved" withString:@""];
							[tempString stringByReplacingOccurrencesOfString:@"All rights reserved" withString:@""];
							[tempString stringByReplacingOccurrencesOfString:@"All Rights Reserved" withString:@""];
							
							currentMovie.copyright = tempString;
						}


						if (!unattended) {
								printf(" OK\n");
						}
					}
					
					
				}
				
			}
			
			
			//////////////////////
			// Content Rating
			//
			if (!currentMovie.contentAdvisoryRating) {
				NSInteger index = indexOfITunesCodes(currentMovie.mpaaiTunes, [mp4File.metadata allITunesCodes]);
				currentMovie.contentAdvisoryRating = [[mp4File.metadata allITunesCodes] objectAtIndex:index];
			}
			
			
			
			//////////////////////
			// Short Description
			//
			
			if ( ([currentMovie.shortdescription isEqualToString:@""]) && (![currentMovie.plot isEqualToString:@""]) ) {
				
				NSRange stringRange = {0, MIN([currentMovie.plot length], 225)};
				stringRange = [currentMovie.plot rangeOfComposedCharacterSequencesForRange:stringRange];
				
				// Now you can create the short string
				currentMovie.shortdescription = [[currentMovie.plot substringWithRange:stringRange] stringByAppendingString:@"..."];
			}
		
			//////////////////////
			// Download Artwork to NSImage
			//
			
			if ((!hasArtwork) || (ignoreTags)) {
				
				if ([currentMovie.thumbs count] > 0) {
					if (!unattended) {
						printf("Downloading artwork...");
					}
					
//					Thumb *curThumb = [currentMovie.thumbs objectAtIndex:[currentMovie.thumbs count] -1 ];
					Thumb *curThumb = [currentMovie.thumbs objectAtIndex:0];
					NSURL *artworkUrl = [NSURL URLWithString:curThumb.value];
					NSImage *artwork = [[NSImage alloc] initWithContentsOfURL:artworkUrl];
					NSData *data = [[NSData alloc] init];
					NSString *artworkExt = nil;
					
					NSBitmapImageRep *imgRep = [[artwork representations] objectAtIndex: 0];
					
					if ([curThumb.value hasSuffix:@".jpg"]) {
						data = [imgRep representationUsingType: NSJPEGFileType properties: nil];
						artworkExt = @"jpg";
					} else if ([curThumb.value hasSuffix:@".png"]) {
						data = [imgRep representationUsingType: NSPNGFileType properties: nil];
						artworkExt = @"png";
					}
					
					NSArray * imageReps = [NSBitmapImageRep imageRepsWithData:data];
					
					NSInteger width = 0;
					NSInteger height = 0;
					
					int curType = 0;
					
					NSString *artworkType = nil;
					
					for (NSImageRep * imageRep in imageReps) {
						if ([imageRep pixelsWide] > width) width = [imageRep pixelsWide];
						if ([imageRep pixelsHigh] > height) height = [imageRep pixelsHigh];
					}
					
					
					CGFloat wFloat = [[NSNumber numberWithInteger:width] floatValue];
					CGFloat hFloat = [[NSNumber numberWithInteger: height] floatValue];
					CGFloat aspRatio = (wFloat / hFloat);
					
					
					// Poster: 800 x 1200
					// Aspect: 0.666
					//
					if ((aspRatio > 0.6) && (aspRatio < 0.72)) {
						artworkType = @"poster";
						curType = 1;
					}
					
					// Banner: 758 x 140
					// Aspect: 5.414
					else if ((aspRatio > 5.3) && (aspRatio < 5.5)) {
						artworkType = @"banner";
						curType = 2;
					}
					
					// Sqaure: 758 x 140
					// Aspect: 1.0
					else if ((aspRatio > 0.9) && (aspRatio < 1.1)) {
						artworkType = @"square";
						curType = 3;
					}
					
					// Fanart: 720p
					else if ((width == 1280) && (height == 720)) {
						artworkType = @"fanart";
						curType = 4;
					}
					
					// Fanart: 1080p
					else if ((width == 1920) && (height == 1080)) {
						artworkType = @"fanart";
						curType = 4;
					}
					
					artworkFilename = [NSString stringWithFormat:@"%@/%@-%@.%@", inputDir, fileName, artworkType, artworkExt];
					
					
					[data writeToFile:artworkFilename atomically: NO];
					
					if (!unattended) {
						printf(" OK\n");
					}
				}
				
				
				// Fanart
				if ([currentMovie.fanarts count] > 0) {
					if (!unattended) {
						printf("Downloading fanart...");
					}
					
					//					Thumb *curThumb = [currentMovie.thumbs objectAtIndex:[currentMovie.thumbs count] -1 ];
					Thumb *curThumb = [currentMovie.fanarts objectAtIndex:0];
					NSURL *artworkUrl = [NSURL URLWithString:curThumb.value];
					NSImage *artwork = [[NSImage alloc] initWithContentsOfURL:artworkUrl];
					NSData *data = [[NSData alloc] init];
					NSString *artworkExt = nil;
					
					NSBitmapImageRep *imgRep = [[artwork representations] objectAtIndex: 0];
					
					if ([curThumb.value hasSuffix:@".jpg"]) {
						data = [imgRep representationUsingType: NSJPEGFileType properties: nil];
						artworkExt = @"jpg";
					} else if ([curThumb.value hasSuffix:@".png"]) {
						data = [imgRep representationUsingType: NSPNGFileType properties: nil];
						artworkExt = @"png";
					}
					
					NSArray * imageReps = [NSBitmapImageRep imageRepsWithData:data];
					
					NSInteger width = 0;
					NSInteger height = 0;
					
					int curType = 0;
					
					NSString *artworkType = nil;
					
					for (NSImageRep * imageRep in imageReps) {
						if ([imageRep pixelsWide] > width) width = [imageRep pixelsWide];
						if ([imageRep pixelsHigh] > height) height = [imageRep pixelsHigh];
					}
					
					
					CGFloat wFloat = [[NSNumber numberWithInteger:width] floatValue];
					CGFloat hFloat = [[NSNumber numberWithInteger: height] floatValue];
					CGFloat aspRatio = (wFloat / hFloat);
					
					
					// Poster: 800 x 1200
					// Aspect: 0.666
					//
					if ((aspRatio > 0.6) && (aspRatio < 0.72)) {
						artworkType = @"poster";
						curType = 1;
					}
					
					// Banner: 758 x 140
					// Aspect: 5.414
					else if ((aspRatio > 5.3) && (aspRatio < 5.5)) {
						artworkType = @"banner";
						curType = 2;
					}
					
					// Sqaure: 758 x 140
					// Aspect: 1.0
					else if ((aspRatio > 0.9) && (aspRatio < 1.1)) {
						artworkType = @"square";
						curType = 3;
					}
					
					// Fanart: 720p
					else if ((width == 1280) && (height == 720)) {
						artworkType = @"fanart";
						curType = 4;
					}
					
					// Fanart: 1080p
					else if ((width == 1920) && (height == 1080)) {
						artworkType = @"fanart";
						curType = 4;
					}
					
					fanartFilename = [NSString stringWithFormat:@"%@/%@-%@.%@", inputDir, fileName, artworkType, artworkExt];
					
					
					[data writeToFile:fanartFilename atomically: NO];
					
					if (!unattended) {
						printf(" OK\n");
					}
				}
			}
			

			//////////////////////
			// Write Tags
			//
			if (tag) {
				
				NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] init] autorelease];
				
				if (!unattended) {
						printf("Tagging movie...");
				}
				
				
				NSError *outError = nil;
				BOOL success = NO;
				
				[mp4File.metadata removeAllArtworks];
				
				if ([mp4File hasFileRepresentation]) {
					success = [mp4File updateMP4FileWithAttributes:attributes error:&outError];
				}

				
				if (!success) {
					printf("\nError: %s\n", [[outError localizedDescription] UTF8String]);
					return -1;
				} else {
					if (!unattended) {
						printf(" OK\n");
					}
				}
				

				
				
				// First: Poster
				if (artworkFilename != nil) {
					[mp4File.metadata setTag:artworkFilename forKey:@"Artwork"];
				}

				// Second: Fanart
				if (fanartFilename != nil) {
					[mp4File.metadata setTag:fanartFilename forKey:@"Artwork"];
				}
				// Third: ???
				
				
				if (![currentMovie.title isEqualToString:@""]) {
					[mp4File.metadata setTag:currentMovie.title forKey:@"Name"];
				}
				
				if ([currentMovie.genres  count] > 0) {
					[mp4File.metadata setTag:[currentMovie.genres objectAtIndex:0] forKey:@"Genre"];
				}
				
				if (![currentMovie.releasedate isEqualToString:@""]) {
					[mp4File.metadata setTag:currentMovie.releasedate forKey:@"Release Date"];
				}
				
				if (![currentMovie.plot isEqualToString:@""]) {
					[mp4File.metadata setTag:currentMovie.plot forKey:@"Long Description"];
					
					[mp4File.metadata setTag:currentMovie.shortdescription forKey:@"Description"];
				}
				
				if (currentMovie.contentID != 0) {
					[mp4File.metadata setTag:[NSNumber numberWithInteger:currentMovie.contentID] forKey:@"contentID"];
				}
				
				if (currentMovie.storeID != nil) {
					[mp4File.metadata setTag:currentMovie.storeID forKey:@"iTunes Country"];
				}
				
				if (currentMovie.kind != 0) {
					[mp4File.metadata setTag:[NSNumber numberWithInteger:currentMovie.kind] forKey:@"Media Kind"];
				}
				
				[mp4File.metadata setTag:currentMovie.copyright forKey:@"Copyright"];
				
				
				//////////////////////
				// Content Rating
				//
				if (![currentMovie.contentAdvisoryRating isEqualToString:@""]) {
					NSInteger index = indexOfITunesCodes(currentMovie.mpaaiTunes, [mp4File.metadata allITunesCodes]);
					[mp4File.metadata setTag:[NSNumber numberWithInteger:index] forKey:@"Rating"];
				}
				
				//////////////////////
				// Cast
				//
				NSMutableArray *actorNames = [[NSMutableArray alloc] init];
				for (int i=0; i < [currentMovie.actors count]; i++) {
					Actor *curActor = [[currentMovie actors] objectAtIndex:i];
					[actorNames addObject:curActor.name];
					if (i == 9) {
						break;
					}
				}
				NSMutableArray *filteredCast = [[[[NSOrderedSet alloc] initWithArray:actorNames] array] mutableCopy];
				
				NSString *castString = [filteredCast componentsJoinedByString:@", "];
				[mp4File.metadata setTag:castString forKey:@"Cast"];
				
				//////////////////////
				// directors
				//
				actorNames = [[NSMutableArray alloc] init];
				for (int i=0; i < [currentMovie.directors count]; i++) {
					Actor *curActor = [[currentMovie directors] objectAtIndex:i];
					[actorNames addObject:curActor.name];
					if (i == 9) {
						break;
					}
				}
				filteredCast = [[[[NSOrderedSet alloc] initWithArray:actorNames] array] mutableCopy];

				castString = [filteredCast componentsJoinedByString:@", "];
				currentMovie.artistname = castString;
				
				[mp4File.metadata setTag:castString forKey:@"Director"];
				[mp4File.metadata setTag:castString forKey:@"Artist"];

				

				
				
				//////////////////////
				// producers
				//
				actorNames = [[NSMutableArray alloc] init];
				for (int i=0; i < [currentMovie.producers count]; i++) {
					Actor *curActor = [[currentMovie producers] objectAtIndex:i];
					[actorNames addObject:curActor.name];
					if (i == 9) {
						break;
					}
				}
				filteredCast = [[[[NSOrderedSet alloc] initWithArray:actorNames] array] mutableCopy];
				
				castString = [filteredCast componentsJoinedByString:@", "];
				[mp4File.metadata setTag:castString forKey:@"Producer"];
				
				
				outError = nil;
				success = NO;
				if ([mp4File hasFileRepresentation]) {
					//success = [mp4File updateMP4FileWithAttributes:attributes error:&outError];
					success = [mp4File updateMP4FileWithAttributes:attributes error:&outError];

				}
//				else if (destinationPath) {
//					if ([mp4File dataSize] > 4100000000 || _64bitchunk) {
//						[attributes setObject:@YES forKey:MP4264BitData];
//					}
//					
//					success = [mp4File writeToUrl:[NSURL fileURLWithPath:destinationPath]
//								   withAttributes:attributes
//											error:&outError];
//				}
				
				if (!success) {
					printf("\nError: %s\n", [[outError localizedDescription] UTF8String]);
					return -1;
				} else {
					if (!unattended) {
						printf(" OK\n");
					}
				}
			

			}
		
		
			
			//////////////////////
			// Write nfo
			//
			if (writenfo) {
				if ([fileManager fileExistsAtPath:nfoTarget]) {
					if (overwritenfo) {
						
						if (!unattended) {
							printf("Writing nfo file...");
							fflush(stdout);
						}
						
						writeXML(currentMovie, nfoTarget);
						
						if (!unattended) {
							printf(" OK\n");
						}
					}
				} else {
					if (!unattended) {
						printf("Writing nfo file...");
						fflush(stdout);
					}
					
					writeXML(currentMovie, nfoTarget);
					if (!unattended) {
						printf(" OK\n");
					}
				}
			}
			
			
			
			//////////////////////
			// Add Movie to processedMovies
			//
			if (verbose) {
				if (!skip) {
					[processedMovies addObject:currentMovie];
				}
			}
			
			
			//////////////////////
			// Display non verbose
			//
			if ((!verbose) && (unattended)) {
				if (noOfFiles > 1) {
					NSString *displayString = [NSString stringWithFormat:@" %3i / %3lu", fileCounter, (unsigned long)noOfFiles];
					progressBar(fileCounter, (int)noOfFiles, PROGRESSBAR_MAX_CALLS, PROGRESSBAR_WIDTH, displayString, currentMovie.title);
				}
			}
			fileCounter++;
			currentMovie = nil;
			skip = NO;
			
		}	// end for loop
		
		//////////////////////
		// Display result
		//
		printf("================================================================\n");
		printf("Number of movies:           %lu	\n", (unsigned long)noOfFiles);
		printf("Number of skipped movies:   %lu	\n", [skippedMovies count]);
		if ([skippedMovies count] > 0) {
			printf("List of skipped movies:			\n");
			for (Movie *curMovie in skippedMovies) {
				printf("\t %s (%s)	\n", [curMovie.title UTF8String], [curMovie.year UTF8String]);
			}
		}
		if (verbose) {
			printf("List of processed movies:	\n");
			if ([processedMovies count] > 0) {
				for (Movie *curMovie in processedMovies) {
					printf("\t %s (%s)	\n", [curMovie.title UTF8String], [curMovie.year UTF8String]);
				}
			}
		}
		printf("Done!\n");
	}
	
	return 0;
}
