//
//  Thumb.h
//  scraper
//
//  Created by michael on 08.01.15.
//  Copyright (c) 2015 michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Thumb : NSObject

@property (nonatomic, retain) NSString* aspect;
@property (nonatomic, retain) NSString* preview;
@property (nonatomic, retain) NSString* value;


-(id) initWithAspect:(NSString *) aAspect
		   andPreview:(NSString *) aPreview
		  andValue:(NSString *) aValue;

@end
