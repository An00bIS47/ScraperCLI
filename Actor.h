//
//  Actor.h
//  scraper
//
//  Created by michael on 08.01.15.
//  Copyright (c) 2015 michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Actor : NSObject

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* role;
@property (nonatomic, retain) NSString* order;
@property (nonatomic, retain) NSString* thumb;

-(id) initWithName:(NSString *) aName;
-(id) initWithName:(NSString *)	aName
		   andRole:(NSString *) aRole
		  andOrder:(NSString *) aOrder
		  andThumb:(NSString *) aThumb;

@end
