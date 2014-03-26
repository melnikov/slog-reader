//
//  FB2DocumentInfo.h
//  NewspaperWorld

#import "GDataXMLNode.h"
#import "FB2Item.h"

@interface FB2DocumentInfo : FB2Item

@property(nonatomic, readonly) NSString *documentID;

- (void)loadFromXMLElement:(GDataXMLElement*)element;

@end
