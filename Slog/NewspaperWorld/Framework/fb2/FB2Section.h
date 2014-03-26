//
//  FB2Section.h
//  NewspaperWorld
//

#import "GDataXMLNode.h"
#import "FB2Epigraph.h"
#import "FB2Image.h"
#import "FB2Annotation.h"
#import "FB2TextItem.h"
#import "FB2Title.h"
#import "FB2Item.h"

@interface FB2Section : FB2Item
{
    NSMutableArray *    _subSections;
    NSMutableArray *    _subItems;
    FB2Title*           _title;
}

- (void)loadFromXMLElement:(GDataXMLElement*)element;

@property (nonatomic, readonly) NSArray*    subSections;

@property (nonatomic, readonly) FB2Title*    title;

@property (nonatomic, readonly) NSArray* subItems;

@end
