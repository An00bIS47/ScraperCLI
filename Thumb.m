//
//  Thumb.m
//  scraper
//
//  Created by michael on 08.01.15.
//  Copyright (c) 2015 michael. All rights reserved.
//

#import "Thumb.h"

@implementation Thumb

-(id) init;
{
	if (self = [super init]) {
		// Initialization code here
		_aspect = @"";
		_preview = @"";
		_value = @"";
	}
	return self;
}

-(id) initWithAspect:(NSString *) aAspect
		  andPreview:(NSString *) aPreview
			andValue:(NSString *) aValue;
{
	if (self = [super init]) {
		// Initialization code here
		_aspect = aAspect;
		_preview = aPreview;
		_value = aValue;
	}
	return self;
}


@end
