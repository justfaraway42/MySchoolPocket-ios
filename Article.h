//
//  Article.h
//  EGW
//
//  Created by Justus Dög on 20.01.13.
//  Copyright (c) 2013 JustProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Article : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSString * title;

@end
