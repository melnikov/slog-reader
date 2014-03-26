//
//  FB2BodyGenerator.m
//  NewspaperWorld
//
//  Created by Эльдар Пикунов on 08.04.13.
//
//

#import "FB2BodyGenerator.h"
#import "FB2PageGeneratorContext.h"
#import "FB2Body.h"
#import "FB2Section.h"

@implementation FB2BodyGenerator

- (void)generatePagesForItem:(FB2Item*)item withContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle
{
    if (![item isKindOfClass:[FB2Body class]])
        return;
    
    FB2Body* body = (FB2Body*)item;

    //header
    if (context.page)
    {
        [context nextPage];
    }
    //sections

    [self generatePagesForSections:body.sections withContext:context parentTitleLastItemID:-1];

    //footer
    if (context.page)
    {
        [context nextPage];
    }
}

- (void)generatePagesForSections:(NSArray*)sections  withContext:(FB2PageGeneratorContext*)context parentTitleLastItemID:(int)lastID
{
    for (FB2Section* section in sections)
    {
        if (lastID == -1 || section.itemID > lastID + 1)
        {
            if (context.page)
            {
                [context nextPage];
            }
            lastID = section.title.lastItemID;
        }

        [section generatePagesWithContext:context parentStyle:nil];
        [self generatePagesForSections:section.subSections withContext:context parentTitleLastItemID:section.title.lastItemID];
    }
}
@end
