// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: meet_msg.proto

#import "GPBProtocolBuffers_RuntimeSupport.h"
#import "MeetMsg.pbobjc.h"
#import "CommonMsg.pbobjc.h"
#import "MeetMsgType.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - MeetMsgRoot

@implementation MeetMsgRoot

+ (GPBExtensionRegistry*)extensionRegistry {
  // This is called by +initialize so there is no need to worry
  // about thread safety and initialization of registry.
  static GPBExtensionRegistry* registry = nil;
  if (!registry) {
    GPBDebugCheckRuntimeVersion();
    registry = [[GPBExtensionRegistry alloc] init];
    [registry addExtensions:[CommonMsgRoot extensionRegistry]];
    [registry addExtensions:[MeetMsgTypeRoot extensionRegistry]];
  }
  return registry;
}

@end

#pragma mark - MeetMsgRoot_FileDescriptor

static GPBFileDescriptor *MeetMsgRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPBDebugCheckRuntimeVersion();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"pms"
                                                     syntax:GPBFileSyntaxProto2];
  }
  return descriptor;
}

#pragma mark - Login

@implementation Login

@dynamic hasUsrFrom, usrFrom;
@dynamic hasUsrToken, usrToken;
@dynamic hasUsrNname, usrNname;

typedef struct Login__storage_ {
  uint32_t _has_storage_[1];
  NSString *usrFrom;
  NSString *usrToken;
  NSString *usrNname;
} Login__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "usrFrom",
        .dataTypeSpecific.className = NULL,
        .number = Login_FieldNumber_UsrFrom,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(Login__storage_, usrFrom),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "usrToken",
        .dataTypeSpecific.className = NULL,
        .number = Login_FieldNumber_UsrToken,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(Login__storage_, usrToken),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "usrNname",
        .dataTypeSpecific.className = NULL,
        .number = Login_FieldNumber_UsrNname,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(Login__storage_, usrNname),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[Login class]
                                     rootClass:[MeetMsgRoot class]
                                          file:MeetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(Login__storage_)
                                         flags:0];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - Logout

@implementation Logout

@dynamic hasUsrFrom, usrFrom;
@dynamic hasUsrToken, usrToken;

typedef struct Logout__storage_ {
  uint32_t _has_storage_[1];
  NSString *usrFrom;
  NSString *usrToken;
} Logout__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "usrFrom",
        .dataTypeSpecific.className = NULL,
        .number = Logout_FieldNumber_UsrFrom,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(Logout__storage_, usrFrom),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "usrToken",
        .dataTypeSpecific.className = NULL,
        .number = Logout_FieldNumber_UsrToken,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(Logout__storage_, usrToken),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[Logout class]
                                     rootClass:[MeetMsgRoot class]
                                          file:MeetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(Logout__storage_)
                                         flags:0];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - Keep

@implementation Keep

@dynamic hasUsrFrom, usrFrom;

typedef struct Keep__storage_ {
  uint32_t _has_storage_[1];
  NSString *usrFrom;
} Keep__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "usrFrom",
        .dataTypeSpecific.className = NULL,
        .number = Keep_FieldNumber_UsrFrom,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(Keep__storage_, usrFrom),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[Keep class]
                                     rootClass:[MeetMsgRoot class]
                                          file:MeetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(Keep__storage_)
                                         flags:0];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - MeetMsg

@implementation MeetMsg

@dynamic hasMsgHead, msgHead;
@dynamic hasMsgTag, msgTag;
@dynamic hasMsgType, msgType;
@dynamic hasUsrFrom, usrFrom;
@dynamic hasMsgCont, msgCont;
@dynamic hasRomId, romId;
@dynamic hasRomName, romName;
@dynamic hasNckName, nckName;
@dynamic hasUsrToken, usrToken;
@dynamic hasMsgSeqs, msgSeqs;
@dynamic hasMemNum, memNum;
@dynamic hasUsrToto, usrToto;

typedef struct MeetMsg__storage_ {
  uint32_t _has_storage_[1];
  EMsgHead msgHead;
  EMsgTag msgTag;
  EMsgType msgType;
  int32_t memNum;
  NSString *usrFrom;
  NSString *msgCont;
  NSString *romId;
  NSString *romName;
  NSString *nckName;
  NSString *usrToken;
  ToUser *usrToto;
  int64_t msgSeqs;
} MeetMsg__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescriptionWithDefault fields[] = {
      {
        .defaultValue.valueEnum = EMsgHead_Hsnd,
        .core.name = "msgHead",
        .core.dataTypeSpecific.enumDescFunc = EMsgHead_EnumDescriptor,
        .core.number = MeetMsg_FieldNumber_MsgHead,
        .core.hasIndex = 0,
        .core.offset = (uint32_t)offsetof(MeetMsg__storage_, msgHead),
        .core.flags = GPBFieldOptional | GPBFieldHasDefaultValue | GPBFieldHasEnumDescriptor,
        .core.dataType = GPBDataTypeEnum,
      },
      {
        .defaultValue.valueEnum = EMsgTag_Tchat,
        .core.name = "msgTag",
        .core.dataTypeSpecific.enumDescFunc = EMsgTag_EnumDescriptor,
        .core.number = MeetMsg_FieldNumber_MsgTag,
        .core.hasIndex = 1,
        .core.offset = (uint32_t)offsetof(MeetMsg__storage_, msgTag),
        .core.flags = GPBFieldOptional | GPBFieldHasDefaultValue | GPBFieldHasEnumDescriptor,
        .core.dataType = GPBDataTypeEnum,
      },
      {
        .defaultValue.valueEnum = EMsgType_Tmsg,
        .core.name = "msgType",
        .core.dataTypeSpecific.enumDescFunc = EMsgType_EnumDescriptor,
        .core.number = MeetMsg_FieldNumber_MsgType,
        .core.hasIndex = 2,
        .core.offset = (uint32_t)offsetof(MeetMsg__storage_, msgType),
        .core.flags = GPBFieldOptional | GPBFieldHasDefaultValue | GPBFieldHasEnumDescriptor,
        .core.dataType = GPBDataTypeEnum,
      },
      {
        .defaultValue.valueString = nil,
        .core.name = "usrFrom",
        .core.dataTypeSpecific.className = NULL,
        .core.number = MeetMsg_FieldNumber_UsrFrom,
        .core.hasIndex = 3,
        .core.offset = (uint32_t)offsetof(MeetMsg__storage_, usrFrom),
        .core.flags = GPBFieldOptional,
        .core.dataType = GPBDataTypeString,
      },
      {
        .defaultValue.valueString = nil,
        .core.name = "msgCont",
        .core.dataTypeSpecific.className = NULL,
        .core.number = MeetMsg_FieldNumber_MsgCont,
        .core.hasIndex = 4,
        .core.offset = (uint32_t)offsetof(MeetMsg__storage_, msgCont),
        .core.flags = GPBFieldOptional,
        .core.dataType = GPBDataTypeString,
      },
      {
        .defaultValue.valueString = nil,
        .core.name = "romId",
        .core.dataTypeSpecific.className = NULL,
        .core.number = MeetMsg_FieldNumber_RomId,
        .core.hasIndex = 5,
        .core.offset = (uint32_t)offsetof(MeetMsg__storage_, romId),
        .core.flags = GPBFieldOptional,
        .core.dataType = GPBDataTypeString,
      },
      {
        .defaultValue.valueString = nil,
        .core.name = "romName",
        .core.dataTypeSpecific.className = NULL,
        .core.number = MeetMsg_FieldNumber_RomName,
        .core.hasIndex = 6,
        .core.offset = (uint32_t)offsetof(MeetMsg__storage_, romName),
        .core.flags = GPBFieldOptional,
        .core.dataType = GPBDataTypeString,
      },
      {
        .defaultValue.valueString = nil,
        .core.name = "nckName",
        .core.dataTypeSpecific.className = NULL,
        .core.number = MeetMsg_FieldNumber_NckName,
        .core.hasIndex = 7,
        .core.offset = (uint32_t)offsetof(MeetMsg__storage_, nckName),
        .core.flags = GPBFieldOptional,
        .core.dataType = GPBDataTypeString,
      },
      {
        .defaultValue.valueString = nil,
        .core.name = "usrToken",
        .core.dataTypeSpecific.className = NULL,
        .core.number = MeetMsg_FieldNumber_UsrToken,
        .core.hasIndex = 8,
        .core.offset = (uint32_t)offsetof(MeetMsg__storage_, usrToken),
        .core.flags = GPBFieldOptional,
        .core.dataType = GPBDataTypeString,
      },
      {
        .defaultValue.valueInt64 = 0LL,
        .core.name = "msgSeqs",
        .core.dataTypeSpecific.className = NULL,
        .core.number = MeetMsg_FieldNumber_MsgSeqs,
        .core.hasIndex = 9,
        .core.offset = (uint32_t)offsetof(MeetMsg__storage_, msgSeqs),
        .core.flags = GPBFieldOptional,
        .core.dataType = GPBDataTypeSInt64,
      },
      {
        .defaultValue.valueInt32 = 0,
        .core.name = "memNum",
        .core.dataTypeSpecific.className = NULL,
        .core.number = MeetMsg_FieldNumber_MemNum,
        .core.hasIndex = 10,
        .core.offset = (uint32_t)offsetof(MeetMsg__storage_, memNum),
        .core.flags = GPBFieldOptional,
        .core.dataType = GPBDataTypeSInt32,
      },
      {
        .defaultValue.valueMessage = nil,
        .core.name = "usrToto",
        .core.dataTypeSpecific.className = GPBStringifySymbol(ToUser),
        .core.number = MeetMsg_FieldNumber_UsrToto,
        .core.hasIndex = 11,
        .core.offset = (uint32_t)offsetof(MeetMsg__storage_, usrToto),
        .core.flags = GPBFieldOptional,
        .core.dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[MeetMsg class]
                                     rootClass:[MeetMsgRoot class]
                                          file:MeetMsgRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescriptionWithDefault))
                                   storageSize:sizeof(MeetMsg__storage_)
                                         flags:GPBDescriptorInitializationFlag_FieldsWithDefault];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)