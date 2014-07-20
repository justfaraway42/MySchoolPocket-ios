//
//  State.h
//  EGW
//
//  Created by Justus Dög on 22.09.12.
//  Copyright (c) 2012 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class State, School;

@interface Community : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) State *communityToState;
@property (nonatomic, retain) NSSet *communityToSchool;
@end

@interface Community (CoreDataGeneratedAccessors)

- (void)addCommunityToSchoolObject:(School *)value;
- (void)removeCommunityToSchoolObject:(School *)value;
- (void)addCommunityToSchool:(NSSet *)values;
- (void)removeCommunityToSchool:(NSSet *)values;

@end
