//
//  Parser.h
//  News
//
//  Created by Justus Dög on 06.07.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Article.h"
#import "Protocols.h"


@interface Parser : NSObject <NSXMLParserDelegate> {
    id<NewsParserDelegate> delegate;
    
    NSMutableData *responseData; // NSMutableData (von NSData) = stellt Datenobjekte zur Verfügung -> in diesem Fall erhält es unsere XML-Daten
    
	NSMutableString *contentsOfCurrentProperty;
	NSManagedObjectContext *managedObjectContext;
    Article *currentArticle;
    
    NSMutableString *currentTitle;
    NSMutableString *currentDate;
    NSMutableString *currentDescription;
    NSMutableString *currentLink;
    
    NSDate *lastArticleDate;
    NSString *lastArticleTitle;
    
    NSMutableArray *mutableFetchResults;
    NSDateFormatter *dateFormatter;
    
    NSInteger allArticles;
    
    NSString *currentElement;
}

@property (strong, nonatomic) NSMutableData *responseData;

@property (strong, nonatomic) NSMutableString *currentTitle;
@property (strong, nonatomic) NSMutableString *currentDate;
@property (strong, nonatomic) NSMutableString *currentDescription;
@property (strong, nonatomic) NSMutableString *currentLink;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)parseXMLFileFrom:(id<NewsParserDelegate>)passedDelegate with:(NSURL *)url;
- (void)addCurrentItem;

@end
