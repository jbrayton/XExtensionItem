@import MobileCoreServices;
@import UIKit;
@import XCTest;
#import "CustomParameters.h"
#import "XExtensionItem.h"

#define XExtensionItemAssertEqualItems(item1, item2) \
    XCTAssertTrue([item1 isKindOfClass:[NSExtensionItem class]]); \
    XCTAssertTrue([item2 isKindOfClass:[NSExtensionItem class]]); \
    XCTAssertEqualObjects(item1.attributedTitle, item2.attributedTitle); \
    XCTAssertEqualObjects(item1.attributedContentText, item2.attributedContentText); \
    XCTAssertEqualObjects(item1.userInfo, item2.userInfo); \
    XCTAssertEqualObjects(item1.attachments, item2.attachments);

@interface XExtensionItemParametersTests : XCTestCase
@end

@implementation XExtensionItemParametersTests

- (void)testItemSourceThrowsIfPlaceholderIsNil {
    XCTAssertThrows([[XExtensionItemSource alloc] initWithPlaceholderItem:nil attachments:nil]);
}

- (void)testAttributedTitle {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    itemSource.attributedTitle = [[NSAttributedString alloc] initWithString:@"Foo" attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:20] }];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqualObjects(itemSource.attributedTitle.string, xExtensionItem.attributedTitle.string);
}

- (void)testAttributedContentText {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    itemSource.attributedContentText = [[NSAttributedString alloc] initWithString:@"Foo" attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:20] }];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqual(itemSource.attributedContentText.hash, xExtensionItem.attributedContentText.hash);
}

- (void)testAttachments {
    NSURL *URL = [NSURL URLWithString:@"http://apple.com"];
    NSArray *attachments = @[
        [[NSItemProvider alloc] initWithItem:[NSURL URLWithString:@"http://apple.com"] typeIdentifier:(__bridge NSString *)kUTTypeURL],
        [[NSItemProvider alloc] initWithItem:@"Apple’s website" typeIdentifier:(__bridge NSString *)kUTTypeText]
    ];
    
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:URL
                                                                                 attachments:
                                        attachments];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqualObjects(attachments, xExtensionItem.attachments);
}

- (void)testTags {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    itemSource.tags = @[@"foo", @"bar", @"baz"];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqualObjects(itemSource.tags, xExtensionItem.tags);
}

- (void)testSourceURL {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    itemSource.sourceURL = [NSURL URLWithString:@"http://tumblr.com"];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqualObjects(itemSource.sourceURL, xExtensionItem.sourceURL);
}

- (void)testReferrer {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    itemSource.referrer = [[XExtensionItemReferrer alloc] initWithAppName:@"Tumblr"
                                                               appStoreID:@"12345"
                                                             googlePlayID:@"54321"
                                                                   webURL:[NSURL URLWithString:@"http://bryan.io/a94kan4"]
                                                                iOSAppURL:[NSURL URLWithString:@"tumblr://a94kan4"]
                                                            androidAppURL:[NSURL URLWithString:@"tumblr://a94kan4"]];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqualObjects(itemSource.referrer, xExtensionItem.referrer);
}

- (void)testReferrerFromBundle {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    itemSource.referrer = [[XExtensionItemReferrer alloc] initWithAppNameFromBundle:[NSBundle bundleForClass:[self class]]
                                                                         appStoreID:@"12345"
                                                                       googlePlayID:@"54321"
                                                                             webURL:[NSURL URLWithString:@"http://bryan.io/a94kan4"]
                                                                          iOSAppURL:[NSURL URLWithString:@"tumblr://a94kan4"]
                                                                      androidAppURL:[NSURL URLWithString:@"tumblr://a94kan4"]];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    XCTAssertEqualObjects(itemSource.referrer, xExtensionItem.referrer);
}

- (void)testUserInfo {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    itemSource.sourceURL = [NSURL URLWithString:@"http://tumblr.com"];
    itemSource.userInfo = @{ @"foo": @"bar" };
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    // Output params user info dictionary should be a superset of input params user info dictionary
    
    [itemSource.userInfo enumerateKeysAndObjectsUsingBlock:^(id inputKey, id inputValue, BOOL *stop) {
        XCTAssertEqualObjects(xExtensionItem.userInfo[inputKey], inputValue);
    }];
}

- (void)testAddEntriesToUserInfo {
    CustomParameters *inputCustomParameters = [[CustomParameters alloc] init];
    inputCustomParameters.customParameter = @"Value";
    
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    [itemSource addEntriesToUserInfo:inputCustomParameters];
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:[itemSource activityViewController:nil itemForActivityType:nil]];
    
    CustomParameters *outputCustomParameters = [[CustomParameters alloc] initWithDictionary:xExtensionItem.userInfo];
    
    XCTAssertEqualObjects(inputCustomParameters, outputCustomParameters);
}

- (void)testTypeSafety {
    /*
     Try to break things by intentionally using the wrong types for these keys, then calling methods that would only
     exist on the correct object types
     */
    
    NSExtensionItem *item = [[NSExtensionItem alloc] init];
    item.userInfo = @{
        @"x-extension-item": @[],
    };
    
    XExtensionItem *xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:item];
    XCTAssertNoThrow([xExtensionItem.sourceURL absoluteString]);
    
    item = [[NSExtensionItem alloc] init];
    item.userInfo = @{
        @"x-extension-item": @{
            @"source-url": @"",
            @"tags": @{},
            @"referrer-name": @[],
            @"referrer-app-store-id": @[],
            @"referrer-google-play-id": @[],
            @"referrer-web-url": @[],
            @"referrer-ios-app-url": @[],
            @"referrer-android-app-url": @[]
        }
    };
    
    xExtensionItem = [[XExtensionItem alloc] initWithExtensionItem:item];
    XCTAssertNoThrow([xExtensionItem.sourceURL absoluteString]);
    XCTAssertNoThrow(xExtensionItem.tags.count);
    XCTAssertNoThrow([xExtensionItem.referrer.appName stringByAppendingString:@""]);
    XCTAssertNoThrow([xExtensionItem.referrer.appStoreID stringByAppendingString:@""]);
    XCTAssertNoThrow([xExtensionItem.referrer.googlePlayID stringByAppendingString:@""]);
    XCTAssertNoThrow([xExtensionItem.referrer.webURL absoluteString]);
    XCTAssertNoThrow([xExtensionItem.referrer.iOSAppURL absoluteString]);
    XCTAssertNoThrow([xExtensionItem.referrer.androidAppURL absoluteString]);
}

- (void)testRegisteringItemProvidingBlockThrowsIfBlockIsNil {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    
    XCTAssertThrows([itemSource registerItemProvidingBlock:nil forActivityType:UIActivityTypeMail]);
}

- (void)testRegisteringItemProvidingBlockThrowsIfActivityTypeIsNil {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    
    XExtensionItemThumbnailProvidingBlock block = ^UIImage *(CGSize suggestedSize) {
        return nil;
    };
    
    XCTAssertThrows([itemSource registerItemProvidingBlock:block forActivityType:nil]);
}

- (void)testRegisteringItemProvidingBlockReturnsRegisteredItemForTwitterActivity {
    NSString *twitterString = @"Foo";
    
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"Bar" attachments:@[]];
    
    [itemSource registerItemProvidingBlock:^{ return twitterString; } forActivityType:UIActivityTypePostToTwitter];
    
    XCTAssertEqualObjects(twitterString, [itemSource activityViewController:nil itemForActivityType:UIActivityTypePostToTwitter]);
}

- (void)testRegisteringItemProvidingBlockReturnsExtensionItemForNonTwitterActivity {
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"title"];
    
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"Bar" attachments:nil];
    itemSource.attributedTitle = attributedTitle;
    
    [itemSource registerItemProvidingBlock:^{ return @"Foo"; } forActivityType:UIActivityTypePostToTwitter];
    
    NSExtensionItem *expected = [[NSExtensionItem alloc] init];
    expected.attributedTitle = attributedTitle;

    NSExtensionItem *actual = [itemSource activityViewController:nil itemForActivityType:UIActivityTypePostToFacebook];
    
    XExtensionItemAssertEqualItems(expected, actual);
}

- (void)testRegisteringSubjectReturnsRegisteredSubjectForMailActivity {
    NSString *subject = @"Subject";
    
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"Bar" attachments:@[]];
    
    [itemSource registerSubject:subject forActivityType:UIActivityTypeMail];
    
    XCTAssertEqualObjects(subject, [itemSource activityViewController:nil subjectForActivityType:UIActivityTypeMail]);
}

- (void)testRegisteringSubjectReturnsNilForNonMailActivity {
    NSString *subject = @"Subject";
    
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"Bar" attachments:@[]];
    
    [itemSource registerSubject:subject forActivityType:UIActivityTypeMail];
    
    XCTAssertNil([itemSource activityViewController:nil subjectForActivityType:UIActivityTypeMessage]);
}

- (void)testRegisteringSubjectThrowsIfSubjectIsNil {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    
    XCTAssertThrows([itemSource registerSubject:nil forActivityType:UIActivityTypeMail]);
}

- (void)testRegisteringSubjectThrowsIfActivityTypeIsNil {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    
    XCTAssertThrows([itemSource registerSubject:@"" forActivityType:nil]);
}

- (void)testRegisteringThumbnailProvidingBlockReturnsThumbnailForTwitterActivity {
    UIImage *image = [[UIImage alloc] initWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"Bar" attachments:@[]];
    
    [itemSource registerThumbnailProvidingBlock:^UIImage *(CGSize suggestedSize) {
        return image;
    } forActivityType:UIActivityTypePostToTwitter];
    
    XCTAssertEqualObjects(image, [itemSource activityViewController:nil thumbnailImageForActivityType:UIActivityTypePostToTwitter suggestedSize:CGSizeZero]);
}

- (void)testRegisteringThumbnailProvidingBlockReturnsNilForNonTwitterActivity {
    UIImage *image = [[UIImage alloc] initWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"Bar" attachments:@[]];
    
    [itemSource registerThumbnailProvidingBlock:^UIImage *(CGSize suggestedSize) {
        return image;
    } forActivityType:UIActivityTypePostToTwitter];
    
    XCTAssertNil([itemSource activityViewController:nil thumbnailImageForActivityType:UIActivityTypeMail suggestedSize:CGSizeZero]);
}

- (void)testRegisteringThumbnailProvidingBlockThrowsIfBlockIsNil {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    
    XCTAssertThrows([itemSource registerThumbnailProvidingBlock:nil forActivityType:UIActivityTypeMail]);
}

- (void)testRegisteringThumbnailProvidingBlockThrowsIfActivityTypeIsNil {
    XExtensionItemSource *itemSource = [[XExtensionItemSource alloc] initWithPlaceholderItem:@"" attachments:@[]];
    
    XExtensionItemThumbnailProvidingBlock block = ^UIImage *(CGSize suggestedSize) {
        return nil;
    };
    
    XCTAssertThrows([itemSource registerThumbnailProvidingBlock:block forActivityType:nil]);
}

@end
