//
//  RssEntry.h
//  RssReader
//
//  Created by evgeniy on 04/03/2017.
//  Copyright © 2017 evgeniy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RssEntry : NSObject

@property (readonly) NSString *title;
@property (readonly) NSString *fullDescription;
@property (readonly) NSString *shortDescription;
@property (readonly) UIImage *thumbnailImage;
@property (readonly) NSString *urlSource;

- (instancetype)initWithTitle:(NSString*)aTitle
                  description:(NSString*)aDescription
               thumbnailImage:(UIImage *)aThumbnailImage
                    urlSource:(NSString *)aUrlSource;

@end
