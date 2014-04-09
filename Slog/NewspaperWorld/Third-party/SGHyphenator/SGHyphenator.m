//
//  SGHyphenator.m
//  SGHyphenator
//
//  Created by Samuel Grau on 2/28/13.
//  Copyright (c) 2013 Samuel Grau. All rights reserved.
//

#import "SGHyphenator.h"

@interface SGHyphenator ()

@property (nonatomic, retain)	NSString				*sep;
@property (nonatomic, retain)	NSMutableDictionary		*patmap, *excmap;

/**
 * @brief A pattern consists of letters, numbers and dots, e.g.: .mis2s1 Even
 * numbers indicate an unacceptable location for a hyphen, odd numbers
 * indicate an acceptable location. Higher numbers are superior over lower
 * numbers.
 */
- (BOOL)addPattern:(NSString *)aPattern;

- (BOOL)addException:(NSString *)aPattern;

@end

@implementation SGHyphenator

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - Singleton definition
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

static SGHyphenator * sharedInstance = nil;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ (instancetype)sharedInstance {
    @synchronized(self) {
        static dispatch_once_t pred;
        if (sharedInstance == nil) {
            dispatch_once(&pred, ^{
                sharedInstance = [[SGHyphenator alloc] init];
            });
        }
    }
    return sharedInstance;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    
    /* We can't return the shared instance, because it's been init'd */
    NSAssert(NO, @"use the singleton API, not alloc+init");
    return nil;
}



// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark -
#pragma mark Lazy loaders
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (NSMutableDictionary *)patmap {
    if (!_patmap) {
        _patmap = [[NSMutableDictionary alloc] init];
    }
    return _patmap;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (NSMutableDictionary *)excmap {
    if (!_excmap) {
        _excmap = [[NSMutableDictionary alloc] init];
    }
    return _excmap;
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark -
#pragma mark Public methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)resetMaps {
    [[self patmap] removeAllObjects];
    [[self excmap] removeAllObjects];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setPatternFile:(NSString *)path {
	NSError *error = nil;
    NSBundle * bundle = nil;
    NSString * filePath = nil;
    
    NSParameterAssert(path != nil);
    
    [self resetMaps];
    
    bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SGHyphenator" ofType:@"bundle"]];
    if (!bundle) {
        [NSException raise:NSGenericException format:@"No bundle found %@ found", @"SGHyphenator.bundle"];
    }

    filePath = [bundle pathForResource:path ofType:@"txt" inDirectory:@"hyphen_files"];
    if (!filePath) {
        [NSException raise:NSInvalidArgumentException format:@"No file named %@ found", path];
    }

    NSStringEncoding encoding = NSUTF8StringEncoding;
	NSString *s = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&error];
	
	NSArray *lines = [s componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	for (NSUInteger i=0; i<[lines count]; i++) {
		[self addPattern:[lines objectAtIndex:i]];
	}
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setExceptionFile:(NSString *)path {
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (BOOL)addPattern:(NSString *)aPattern {
	NSString *pat = [aPattern stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
	NSArray *numbers = [aPattern componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
	
	NSMutableArray *points = [[NSMutableArray alloc] init];
	for(NSUInteger i=0; i<[numbers count]; i++) {
		if ( [(NSString *)[numbers objectAtIndex:i] compare:@""] == NSOrderedSame ) {
			[points addObject:@(0)];
            
		} else {
			[points addObject:[NSNumber numberWithInt:[[numbers objectAtIndex:i] intValue]]];
		}
	}
	
	[[self patmap] setObject:points forKey:pat];
	
	return YES;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (BOOL)addException:(NSString *)aPattern {
	return YES;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (NSArray *)hyphenate:(NSString *)word {
	// init return var
	NSMutableArray *retlist = [[NSMutableArray alloc] init];
	
	// very short words cannot be hyphenated
	if ( [word length] < 4) {
		[retlist addObject:word];
		return retlist;
	}
	
	NSString *workingword = [NSString stringWithFormat:@".%@.", [word lowercaseString]];
	NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:[workingword length]+1];
	for (NSUInteger k=0; k<[workingword length]+1; k++) {
		[points insertObject:@(0) atIndex:0];
	}
    
	//points = new int[workingword.length() + 1];
	
	// label for a labeled continue
	NSString *tmpword;
	
	// for each char in the .word.
	for (NSUInteger i = 0; i < [workingword length]; i++)  {
		// look for a pattern the actual subsequence starts with
		tmpword = [workingword substringFromIndex:i];
		
		//NSLog(@"working on %@", tmpword);
		
		for (NSUInteger j = 1; j <= [tmpword length]; j++) {
			// read points
			NSRange range = NSMakeRange(0, j);
			NSArray *tpoints = [[self patmap] objectForKey:[tmpword substringWithRange:range]];
			
			if ( tpoints != nil )  {
				//NSLog(@"%@", tpoints);
				//NSLog(@"substring: %@", [tmpword substringWithRange:range]);
				
				// set points if larger than the points already set
				for (NSUInteger l = 0; l < [tpoints count]; l++) {
					if ( [[points objectAtIndex:i+l] compare:[tpoints objectAtIndex:l]] == NSOrderedDescending ) {
						[points replaceObjectAtIndex:i+l withObject:[points objectAtIndex:i+l]];
                        
					} else {
						[points replaceObjectAtIndex:i+l withObject:[tpoints objectAtIndex:l]];
					}
				}
			}
		}
	}
	
	[points replaceObjectAtIndex:0 withObject:@(0)];
	[points replaceObjectAtIndex:1 withObject:@(0)];
	[points replaceObjectAtIndex:2 withObject:@(0)];
	
	NSUInteger len = [points count];
	
	[points replaceObjectAtIndex:len-1 withObject:@(0)];
	[points replaceObjectAtIndex:len-2 withObject:@(0)];
	[points replaceObjectAtIndex:len-3 withObject:@(0)];
	
	NSMutableString *tstr = [[NSMutableString alloc] init];
	
	for (NSUInteger i = 0; i < [points count] - 3; i++) {
		[tstr appendString:[word substringWithRange:NSMakeRange(i, 1)]];
		if ( ([[points objectAtIndex:(i + 2)] intValue] % 2) == 1) {
			[retlist addObject:tstr];
			tstr = nil;
			tstr = [[NSMutableString alloc] init];
		}
		
	}
	
	[retlist addObject:tstr];
		
	return retlist;
}


@end
