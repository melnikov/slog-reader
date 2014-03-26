//
//  NWBookCard.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>

enum NWBookID {
    NWBookIDUndefined = -1
};

@interface NWBookCard : NSObject
{
    int         _ID;

    NSString*   _title;
    
    NSString*   _coverURL;
    
    NSString*   _authors;
    
    int         _approximateReadingInHours;
    
    NSString*   _publisher;
    
    BOOL        _isSold;
    
    NSString*   _demoFragmentURL;
    
    NSString*   _bookAnnotation;
    
    NSString*   _bookPrice;

    NSString*   _language;

    NSString*   _fileType;

    NSString*   _timestamp;
}

+ (NWBookCard*)bookFromResponseData:(NSObject*)data;

- (BOOL)loadFromResponseData:(NSObject*)data;

- (NSDictionary*)saveToDictionary;

@property (nonatomic, readonly) int ID;

@property (nonatomic, readonly) NSString* title;

@property (nonatomic, readonly) NSString* coverURL;

@property (nonatomic, readonly) NSString* authors;

@property (nonatomic, readonly) int approximateReadingInHours;

@property (nonatomic, readonly) NSString* publisher;

@property (nonatomic, assign)   BOOL      isSold;

@property (nonatomic, readonly) NSString* demoFragmentURL;

@property (nonatomic, readonly) NSString* bookAnnotation;

@property (nonatomic, readonly) NSString* bookPrice;

@property (nonatomic, readonly) NSString* language;

@property (nonatomic, readonly) NSString* fileType;

@property (nonatomic, readonly) NSString* timestamp;

@end
