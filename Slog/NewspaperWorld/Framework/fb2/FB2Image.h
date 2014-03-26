//
//  FB2Image.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "FB2Item.h"

@interface FB2Image : FB2Item

+ (FB2Image*)imageFromXMLElement:(GDataXMLElement*)element;

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element;

@property (nonatomic, readonly) NSString* href;

@property (nonatomic, readonly) NSString* binaryID;

/*
 @brief This property indicate how image positioned relative to text
 */
@property (nonatomic, readonly) NSString* align;

/*
 @brief This property contains minimum horizontal margin in pixels between text and image
 */
@property (nonatomic, readonly) int minHorizontalMargin;

/*
 @brief This property contains minimum width of image relative to page
 */
@property (nonatomic, readonly) float maxWidthRelativeToPage;

/*
 @brief This property contains minimum height of image relative to page
 */
@property (nonatomic, readonly) float maxHeightRelativeToPage;

@end
