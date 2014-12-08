#import "XExtensionItemDictionarySerializing.h"
#import "XExtensionItemMutableParameters.h"
#import "XExtensionItemParameters.h"

@implementation XExtensionItemMutableParameters

@synthesize attributedTitle;
@synthesize attributedContentText;
@synthesize attachments;
@synthesize tags;
@synthesize sourceURL;
@synthesize imageURL;
@synthesize location;
@synthesize sourceApplication;
@synthesize UTIsToContentRepresentations;
@synthesize userInfo;

- (void)addEntriesToUserInfo:(id <XExtensionItemDictionarySerializing>)dictionarySerializable {
    self.userInfo = ({
        NSMutableDictionary *mutableUserInfo = [[NSMutableDictionary alloc] initWithDictionary:self.userInfo];
        [mutableUserInfo addEntriesFromDictionary:dictionarySerializable.dictionaryRepresentation];
        mutableUserInfo;
    });
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[XExtensionItemParameters allocWithZone:zone] initWithAttributedTitle:self.attributedTitle
                                                            attributedContentText:self.attributedContentText
                                                                      attachments:self.attachments
                                                                             tags:self.tags
                                                                        sourceURL:self.sourceURL
                                                                         imageURL:self.imageURL
                                                                         location:self.location
                                                                sourceApplication:self.sourceApplication
                                                     UTIsToContentRepresentations:self.UTIsToContentRepresentations
                                                                         userInfo:self.userInfo];
}

@end
