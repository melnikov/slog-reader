//
//  ReviewUrl.m
//  NewspaperWorld
//
//  Created by Eugene Zorin on 11/30/12.
//
//

#import "ReviewUrl.h"

#define EMAIL_FEEDBACK @"info@gmi.ru"
@implementation ReviewUrl


- (BOOL)openURL:(NSURL *)url
{
    NSString* mailUrl = [url absoluteString];
    if ([mailUrl rangeOfString:EMAIL_FEEDBACK].location != NSNotFound)
    {
        NSString* bundleName =[[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleDisplayName"] ;
        
        NSString* newUrl = [[NSString stringWithFormat:NSLocalizedString(@"IDS_REVIEW_TEXT_SUBJ", nil),mailUrl,@"?subject=",bundleName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return [super openURL:[NSURL URLWithString:newUrl]];
    }
    
    return [super openURL:url];
}


@end