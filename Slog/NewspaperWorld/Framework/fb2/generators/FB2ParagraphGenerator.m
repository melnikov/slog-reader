//
//  FB2ParagraphGenerator.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 08.04.13.
//
//

#import "FB2ParagraphGenerator.h"
#import "FB2BlockGenerator.h"
#import "FB2TextItem.h"
#import "FB2Constants.h"
#import "FB2PageGeneratorContext.h"
#import "FB2Paragraph.h"
#import "FB2Image.h"
#import "NSString+MultiThreadDraw.h"

@implementation FB2ParagraphGenerator

- (void)generatePagesForItem:(FB2Item*)item withContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle
{
    if (![item isKindOfClass:[FB2Paragraph class]])
        return;

    FB2Paragraph* paragraph = (FB2Paragraph*)item;

    if (paragraph.subItems.count == 1)
    {
        FB2Item* itemInParagraph = [paragraph.subItems objectAtIndex:0];

        if ([itemInParagraph isKindOfClass:[FB2Image class]])
        {
            FB2Image* fb2Image = (FB2Image*)itemInParagraph;
            [fb2Image generatePagesWithContext:context parentStyle:nil];
            return;
        }
    }

    if (!context.page)        context.page = [FB2PageData pageData];

    if (!parentStyle)
        context.position->x = ([FB2FormattingTAB MTSizeWithFont:paragraph.textStyle.textFont]).width; // add indent in first line of paragraph
    
    FB2BlockGenerator* gen = [[FB2BlockGenerator alloc] init];
    [gen generatePagesForItem:item withContext:context parentStyle:parentStyle];
    [gen release];

    if (paragraph.ID.length > 0)
                [context.page.nodeIDs addObject:paragraph.ID];
}
@end
