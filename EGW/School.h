//
//  School.h
//  EGW
//
//  Created by Justus Dög on 22.09.12.
//  Copyright (c) 2012 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Community;

@interface School : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * timetablesClasses;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * timetablesUrls;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * timetablesNames;
@property (nonatomic, retain) NSString * feed;
@property (nonatomic, retain) NSString * representationUrls;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) Community *schoolToCommunity;

@end
