//
//  FB2PublishInfo.h
//  NewspaperWorld

#import "GDataXMLNode.h"
#import "FB2Item.h"

@interface FB2PublishInfo : FB2Item

- (void)loadFromXMLElement:(GDataXMLElement*)element;

@property (nonatomic, readonly) NSString* originalBookName;

@property (nonatomic, readonly) NSString* publisher;

@end
