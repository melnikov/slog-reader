//
//  NWApiErrors.h
//  NewspaperWorld
//


#ifndef NewspaperWorld_NWApiErrors_h
#define NewspaperWorld_NWApiErrors_h

/// error domains
static NSString * const NWApiErrorDomainHttp       = @"HttpErrors";
static NSString * const NWApiErrorDomainFormat     = @"FormatErrors";
static NSString * const NWApiErrorDomainServerApi  = @"ServerApiErrors";

/// server api response codes
enum {
    kNWApiResponseCodeSuccess                   = 0,
    kNWApiResponseCodeWrongParameters           = 1,
    kNWApiResponseCodeWrongParameterType        = 2,
    kNWApiResponseCodeWrongMethodAuthorization  = 3
};

#endif
