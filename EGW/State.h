//
//  Country.h
//  EGW
//
//  Created by Justus Dög on 22.09.12.
//  Copyright (c) 2012 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Community;

@interface State : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *stateToCommunity;
@end

@interface State (CoreDataGeneratedAccessors)

- (void)addStateToCommunityObject:(Community *)value;
- (void)removeStateToCommunityObject:(Community *)value;
- (void)addStateToCommunity:(NSSet *)values;
- (void)removeStateToCommunity:(NSSet *)values;

@end
