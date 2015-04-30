#import "XExtensionItemAttachment.h"
#import "XExtensionItemMutableParameters.h"
#import "XExtensionItemParameters.h"
#import "XExtensionItemSourceApplication.h"
#import "XExtensionItemTypeSafeDictionaryValues.h"

static NSString * const ParameterKeyXExtensionItem = @"x-extension-item";
static NSString * const ParameterKeyImageURL = @"image-url";
static NSString * const ParameterKeyAlternateContentRepresentations = @"alternate-content-representations";
static NSString * const ParameterKeySourceURL = @"source-url";
static NSString * const ParameterKeyTags = @"tags";

@implementation XExtensionItemParameters

#pragma mark - Initialization

- (instancetype)initWithBlock:(void (^)(XExtensionItemMutableParameters *))initializationBlock {
    NSParameterAssert(initializationBlock);
    
    XExtensionItemMutableParameters *parameters = [[XExtensionItemMutableParameters alloc] init];
    
    if (initializationBlock) {
        initializationBlock(parameters);
    }
    
    return [self initWithAttributedTitle:parameters.attributedTitle
                   attributedContentText:parameters.attributedContentText
                             attachments:parameters.attachments
                                    tags:parameters.tags
                               sourceURL:parameters.sourceURL
                                imageURL:parameters.imageURL
                       sourceApplication:parameters.sourceApplication
         alternateContentRepresentations:parameters.alternateContentRepresentations
                                userInfo:parameters.userInfo];
}

- (instancetype)initWithAttributedTitle:(NSAttributedString *)attributedTitle
                  attributedContentText:(NSAttributedString *)attributedContentText
                            attachments:(NSArray *)attachments
                                   tags:(NSArray *)tags
                              sourceURL:(NSURL *)sourceURL
                               imageURL:(NSURL *)imageURL
                      sourceApplication:(XExtensionItemSourceApplication *)sourceApplication
        alternateContentRepresentations:(NSDictionary *)alternateContentRepresentations
                               userInfo:(NSDictionary *)userInfo {
    self = [super init];
    if (self) {
        _attributedTitle = [attributedTitle copy];
        _attributedContentText = [attributedContentText copy];
        _attachments = attachments;
        _tags = [tags copy];
        _sourceURL = [sourceURL copy];
        _imageURL = [imageURL copy];
        _sourceApplication = sourceApplication;
        _alternateContentRepresentations = [alternateContentRepresentations copy];
        _userInfo = [userInfo copy];
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithAttributedTitle:nil
                   attributedContentText:nil
                             attachments:nil
                                    tags:nil
                               sourceURL:nil
                                imageURL:nil
                       sourceApplication:nil
            alternateContentRepresentations:nil
                                userInfo:nil];
}

#pragma mark - NSExtensionItem conversion

- (instancetype)initWithExtensionItem:(NSExtensionItem *)extensionItem {
    NSDictionary *parameterDictionary = [[[XExtensionItemTypeSafeDictionaryValues alloc] initWithDictionary:extensionItem.userInfo]
                                         dictionaryForKey:ParameterKeyXExtensionItem];
    
    XExtensionItemTypeSafeDictionaryValues *parameters = [[XExtensionItemTypeSafeDictionaryValues alloc] initWithDictionary:parameterDictionary];

    XExtensionItemSourceApplication *sourceApplication = [[XExtensionItemSourceApplication alloc] initWithDictionary:parameterDictionary];
    
    return [self initWithAttributedTitle:extensionItem.attributedTitle
                   attributedContentText:extensionItem.attributedContentText
#warning These need to be converted to `XExtensionItemAttachments`
                             attachments:extensionItem.attachments
                                    tags:[parameters arrayForKey:ParameterKeyTags]
                               sourceURL:[parameters URLForKey:ParameterKeySourceURL]
                                imageURL:[parameters URLForKey:ParameterKeyImageURL]
                       sourceApplication:sourceApplication
         alternateContentRepresentations:[parameters dictionaryForKey:ParameterKeyAlternateContentRepresentations]
                                userInfo:extensionItem.userInfo];
}

#pragma mark - NSObject

- (NSString *)description {
    NSMutableString *mutableDescription = [[NSMutableString alloc] initWithFormat:@"%@ { attachments: %@",
                                           [super description], self.attachments];
    
    if (self.attributedTitle) {
        [mutableDescription appendFormat:@", attributedTitle: %@", self.attributedTitle];
    }
    
    if (self.attributedContentText) {
        [mutableDescription appendFormat:@", attributedContentText: %@", self.attributedContentText];
    }
    
    if (self.tags) {
        [mutableDescription appendFormat:@", tags: %@", self.tags];
    }
    
    if (self.sourceURL) {
        [mutableDescription appendFormat:@", sourceURL: %@", self.sourceURL];
    }
    
    if (self.imageURL) {
        [mutableDescription appendFormat:@", imageURL: %@", self.imageURL];
    }
    
    if (self.sourceApplication) {
        [mutableDescription appendFormat:@", sourceApplication: %@", self.sourceApplication];
    }
    
    if (self.alternateContentRepresentations) {
        [mutableDescription appendFormat:@", alternateContentRepresentations: %@", self.alternateContentRepresentations];
    }
    
    if (self.userInfo) {
        [mutableDescription appendFormat:@", userInfo: %@", ({
            NSMutableDictionary *mutableUserInfo = [self.userInfo mutableCopy];
            
            for (NSString *key in @[NSExtensionItemAttributedTitleKey, NSExtensionItemAttributedContentTextKey, NSExtensionItemAttachmentsKey]) {
                [mutableUserInfo removeObjectForKey:key];
            }
            
            // Remove values used internally by this class
            [mutableUserInfo removeObjectForKey:ParameterKeyXExtensionItem];
            
            [mutableUserInfo copy];
        })];
    }
    
    [mutableDescription appendFormat:@" }"];
    
    return [mutableDescription copy];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[XExtensionItemMutableParameters alloc] initWithAttributedTitle:self.attributedTitle
                                                      attributedContentText:self.attributedContentText
                                                                attachments:self.attachments
                                                                       tags:self.tags
                                                                  sourceURL:self.sourceURL
                                                                   imageURL:self.imageURL
                                                          sourceApplication:self.sourceApplication
                                            alternateContentRepresentations:self.alternateContentRepresentations
                                                                   userInfo:self.userInfo];
}

#pragma mark - UIActivityItemSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    XExtensionItemAttachment *firstAttachment = self.attachments.firstObject;
    
    return firstAttachment.item;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    NSExtensionItem *item = [[NSExtensionItem alloc] init];
    item.userInfo = ({
        NSMutableDictionary *mutableUserInfo = [[NSMutableDictionary alloc] init];
        [mutableUserInfo addEntriesFromDictionary:self.userInfo];
        
        NSMutableDictionary *mutableParameters = [[NSMutableDictionary alloc] init];
        [mutableParameters setValue:self.tags forKey:ParameterKeyTags];
        [mutableParameters setValue:self.sourceURL forKey:ParameterKeySourceURL];
        [mutableParameters setValue:self.imageURL forKey:ParameterKeyImageURL];
        [mutableParameters setValue:self.alternateContentRepresentations forKey:ParameterKeyAlternateContentRepresentations];
        [mutableParameters addEntriesFromDictionary:self.sourceApplication.dictionaryRepresentation];
        
        if ([mutableParameters count] > 0) {
            mutableUserInfo[ParameterKeyXExtensionItem] = [mutableParameters copy];
        }
        
        mutableUserInfo;
    });
    
    /*
     The `userInfo` setter *must* be called before the following three setters, which merely provide syntactic sugar for
     populating the `userInfo` dictionary with the following keys:
     
     * `NSExtensionItemAttributedTitleKey`,
     * `NSExtensionItemAttributedContentTextKey`
     * `NSExtensionItemAttachmentsKey`.

     */
    item.attachments = [[self class] transformArray:self.attachments usingBlock:^NSItemProvider *(XExtensionItemAttachment *attachment) {
        return [[NSItemProvider alloc] initWithItem:attachment.item typeIdentifier:attachment.typeIdentifier];
    }];
    item.attributedTitle = self.attributedTitle;
    item.attributedContentText = self.attributedContentText;
    
    return item;
}

#pragma mark - Private

+ (NSArray *)transformArray:(NSArray *)array usingBlock:(id (^)(id))block {
    NSParameterAssert(block);
    
    NSMutableArray *transformed = [[NSMutableArray alloc] init];
    
    if (block) {
        for (id object in array) {
            [transformed addObject:block(object)];
        }
    }
    
    return [transformed copy];
}

@end
