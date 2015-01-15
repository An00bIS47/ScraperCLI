//
//  Actor.m
//  scraper
//
//  Created by michael on 08.01.15.
//  Copyright (c) 2015 michael. All rights reserved.
//

#import "Actor.h"

@implementation Actor

-(id) init;
{
	if (self = [super init]) {
		// Initialization code here
		_name = @"";
		_role = @"";
		_order = @"";
		_thumb = @"";
	}
	return self;
}

-(id) initWithName:(NSString *) aName;
{
	if (self = [super init]) {
		// Initialization code here
		_name = aName;
		_role = @"";
		_order = @"";
		_thumb = @"";
	}
	return self;
}

-(id) initWithName:(NSString *)	aName
		   andRole:(NSString *) aRole
		  andOrder:(NSString *) aOrder
		  andThumb:(NSString *) aThumb;
{
	if (self = [super init]) {
		// Initialization code here
		_name = aName;
		_role = aRole;
		_order = aOrder;
		_thumb = aThumb;
	}
	return self;
}

@end
