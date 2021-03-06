//
//  MSSqlite3.h
//  SdkMsgClientIos
//
//  Created by hp on 6/28/16.
//  Copyright © 2016 Dync. All rights reserved.
//

#ifndef MSSqlite3_h
#define MSSqlite3_h

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface MSSqlite3DB : NSObject;

@property (nonatomic, assign) sqlite3* sql3Db;

- (BOOL)openDb;

- (BOOL)closeDb;

- (BOOL)isUserExistsInDb:(NSString*)userId;

- (BOOL)insertSeqnSeqnId:(NSString*)seqnId
                 seqn:(NSNumber*)seqn;

- (BOOL)updateSeqnSeqnId:(NSString*)seqnId
                    seqn:(NSNumber*)seqn;

- (BOOL)updateSeqnSeqnId:(NSString*)seqnId
                    seqn:(NSNumber*)seqn
               isfetched:(NSNumber*)isfetched;

- (BOOL)selectSeqnSeqnId:(NSString*)seqnId
                    seqn:(NSNumber**)seqn;

- (BOOL) deleteSeqnSeqnId:(NSString*)seqnId;


- (BOOL)insertGroupIdGrpId:(NSString*)grpId;

- (BOOL)selectGroupInfo:(NSMutableArray**)Info;

- (BOOL)deleteGroupIdGrpId:(NSString*)grpId;

@end

#endif /* MSSqlite3_h */
