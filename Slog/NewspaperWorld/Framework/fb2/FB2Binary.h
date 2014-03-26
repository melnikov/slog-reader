//
//  FB2Binary.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "FB2Item.h"

static NSString* const FB2BinaryTypeUndefined = @"";
static NSString* const FB2BinaryTypeJPEG = @"image/jpeg";
static NSString* const FB2BinaryTypePNG = @"image/png";

@interface FB2Binary : FB2Item

- (void)loadFromXMLElement:(GDataXMLElement*)element;

@property (nonatomic, readonly) NSString* type;

@property (nonatomic, readonly) NSString* ID;

@property (nonatomic, readonly) NSData* decodedData;

@end
