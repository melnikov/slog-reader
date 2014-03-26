//
//  FB2Body.h
//

#import "GDataXMLNode.h"
#import "FB2Image.h"
#import "FB2TextItem.h"
#import "FB2Title.h"
#import "FB2Item.h"

@interface FB2Body : FB2Item
{
    NSMutableArray *_sections;
    
    NSMutableArray* _epigraphs;
    
    FB2Title* _title;
}

- (void)loadFromXMLElement:(GDataXMLElement*)element;

@property(nonatomic, readonly) FB2Title *title;

@property(nonatomic, readonly) FB2Image* image;

@property(nonatomic, readonly) NSArray* epigraphs;

@property(nonatomic, readonly) NSArray* sections;

@end
