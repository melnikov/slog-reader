//
//  FB2FormattedTextItemFactory.m
//  NewspaperWorld
//

#import "FB2ItemFactory.h"
#import "FB2Paragraph.h"
#import "FB2Subtitle.h"
#import "FB2EmptyLine.h"
#import "FB2Image.h"
#import "FB2PlainText.h"
#import "FB2Title.h"
#import "FB2Table.h"
#import "FB2Cite.h"
#import "FB2BoldTextItem.h"
#import "FB2EmphasisTextItem.h"
#import "FB2Style.h"
#import "FB2Stanza.h"
#import "FB2V.h"
#import "FB2Title.h"
#import "FB2Poem.h"
#import "FB2Cite.h"
#import "FB2Link.h"
#import "FB2Subscript.h"
#import "FB2SuperScript.h"
#import "FB2StrikeThrough.h"
#import "FB2Annotation.h"
#import "FB2Epigraph.h"
#import "FB2Date.h"
#import "FB2Constants.h"

@implementation FB2ItemFactory

+ (id)itemFromXMLElement:(GDataXMLElement*)element
{
    id result = nil;

    if ([element.name isEqualToString:FB2ElementParagraph]) result = [FB2Paragraph  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementSubtitle])  result = [FB2Subtitle   itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementEmptyLine]) result = [FB2EmptyLine  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementImage])     result = [FB2Image      imageFromXMLElement:element];
    if (element.kind == GDataXMLTextKind)                   result = [FB2PlainText  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementTable])     result = [FB2Table  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementCite])      result = [FB2Cite  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementStrong])    result = [FB2BoldTextItem  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementEmphasis])  result = [FB2EmphasisTextItem  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementStyle])     result = [FB2Style  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementStanza])    result = [FB2Stanza  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementV])         result = [FB2V  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementPoem])      result = [FB2Poem  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementLink])      result = [FB2Link  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementSubscript]) result = [FB2Subscript  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementSuperScript])   result = [FB2SuperScript  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementStrikeThrough]) result = [FB2StrikeThrough  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementEpigraph])      result = [FB2Epigraph  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementAnnotation])    result = [FB2Annotation  itemFromXMLElement:element];
    if ([element.name isEqualToString:FB2ElementTitle])         result = [FB2Title  itemFromXMLElement:element];

    return result;
}

@end
