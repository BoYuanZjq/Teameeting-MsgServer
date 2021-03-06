//
//  MsgClient.mm
//  MsgClientIos
//
//  Created by hp on 12/25/15.
//  Copyright (c) 2015 Dync. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgClient.h"
#import "MSTxtMessage.h"
#import "CommonMsg.pbobjc.h"
#import "EntityMsg.pbobjc.h"
#import "EntityMsgType.pbobjc.h"

#import "entity_msg.pb.h"
#import "entity_msg_type.pb.h"

int MsgClient::MCInit(const std::string& uid, const std::string& token, const std::string& nname)
{
    std::cout << "MCInit add module here, please implement it!!!" << std::endl;
    m_strUserId = uid;
    m_strToken = token;
    m_strNname = nname;
    m_nsUserId = [[NSString alloc] initWithUTF8String:uid.c_str()];
    m_nsToken = [[NSString alloc] initWithUTF8String:token.c_str()];
    m_nsNname = [[NSString alloc] initWithUTF8String:nname.c_str()];
    
    m_isFetched = false;
    m_nsGroupInfo = [[NSMutableArray alloc] init];
    m_recurLock = [[NSRecursiveLock alloc] init];
    m_sqlite3Manager = [[MSSqlite3Manager alloc] init];
    [m_sqlite3Manager initManager];
    CheckUserOrInit(m_nsUserId);
    GetLocalSeqnsFromDb();
    return Init(uid, token, nname, pms::EModuleType(EModuleType_Tlive));
}

int MsgClient::MCUnin()
{
    PutLocalSeqnsToDb();
    if (m_sqlite3Manager)
    {
        [m_sqlite3Manager uninManager];
    }
    m_isFetched = false;
    return Unin();
}

int MsgClient::MCRegisterMsgCb(XMsgCallback* cb)
{
    return RegisterMsgCb(cb);
}

int MsgClient::MCUnRegisterMsgCb(XMsgCallback* cb)
{
    return UnRegisterMsgCb(cb);
}

int MsgClient::MCConnToServer(const std::string& server, int port)
{
    ConnToServer(server, port);
    return 0;
}


int MsgClient::MCAddGroup(const std::string& groupid)
{
    AddGroup(groupid);
    return 0;
}

int MsgClient::MCRmvGroup(const std::string& groupid)
{
    RmvGroup(groupid);
    return 0;
}


int MsgClient::MCSyncSeqn()
{
    if (m_isFetched)
    {
        for (auto &it : m_groupSeqn)
        {
            if (m_strUserId.compare(it.first))
            {
                SyncGroupSeqn(it.first, it.second, EMsgRole_Rsender);
            } else {
                SyncSeqn(it.second, EMsgRole_Rsender);
            }
        }
    } else {
        NSLog(@"MCSyncSeqn should be fetched before called");
        FetchAllSeqns();
    }
    return 0;
}


int MsgClient::MCSyncMsg()
{
    if (m_isFetched)
    {
        for (auto &it : m_groupSeqn)
        {
            if (m_strUserId.compare(it.first))
            {
                SyncGroupData(it.first, it.second);
            } else {
                SyncData(it.second);
            }
        }
    } else {
        NSLog(@"MCSyncMsg should be fetched before called");
        FetchAllSeqns();
    }
    return 0;
}

int MsgClient::MCSendTxtMsg(std::string& outmsgid, const std::string& groupid, const std::string& content)
{
    return SndMsg(outmsgid, groupid, "roomname", content, (pms::EMsgTag)EMsgTag_Tchat, (pms::EMsgType)EMsgType_Ttxt, (pms::EModuleType)EModuleType_Tlive, (pms::EMsgFlag)EMsgFlag_Fgroup);
}

int MsgClient::MCSendTxtMsgToUsr(std::string& outmsgid, const std::string& userid, const std::string& content)
{
    std::vector<std::string> uvec;
    uvec.push_back(userid);
    return SndMsgTo(outmsgid, "groupid", "grpname", content, (pms::EMsgTag)EMsgTag_Tchat, (pms::EMsgType)EMsgType_Ttxt, (pms::EModuleType)EModuleType_Tlive, (pms::EMsgFlag)EMsgFlag_Fsingle, uvec);
}

int MsgClient::MCSendTxtMsgToUsrs(std::string& outmsgid, const std::vector<std::string>& vusrs, const std::string& content)
{
    return SndMsgTo(outmsgid, "groupid", "grpname", content, (pms::EMsgTag)EMsgTag_Tchat, (pms::EMsgType)EMsgType_Ttxt, (pms::EModuleType)EModuleType_Tlive, (pms::EMsgFlag)EMsgFlag_Fsingle, vusrs);
}


int MsgClient::MCNotifyLive(std::string& outmsgid, const std::string& groupid, const std::string& hostid)
{
    std::vector<std::string> uvec;
    uvec.push_back(hostid);
    return SndMsgTo(outmsgid, groupid, "grpname", "", (pms::EMsgTag)EMsgTag_Tchat, (pms::EMsgType)EMsgType_Tliv, (pms::EModuleType)EModuleType_Tlive, (pms::EMsgFlag)EMsgFlag_Fsingle, uvec);
}

int MsgClient::MCNotifyRedEnvelope(std::string& outmsgid, const std::string& groupid, const std::string& hostid)
{
    std::vector<std::string> uvec;
    uvec.push_back(hostid);
    return SndMsgTo(outmsgid, groupid, "grpname", "", (pms::EMsgTag)EMsgTag_Tchat, (pms::EMsgType)EMsgType_Tren, (pms::EModuleType)EModuleType_Tlive, (pms::EMsgFlag)EMsgFlag_Fsingle, uvec);
}

int MsgClient::MCNotifyBlacklist(std::string& outmsgid, const std::string& groupid, const std::string& userid)
{
    std::vector<std::string> uvec;
    uvec.push_back(userid);
    return SndMsgTo(outmsgid, groupid, "grpname", "", (pms::EMsgTag)EMsgTag_Tchat, (pms::EMsgType)EMsgType_Tblk, (pms::EModuleType)EModuleType_Tlive, (pms::EMsgFlag)EMsgFlag_Fsingle, uvec);
}

int MsgClient::MCNotifyForbidden(std::string& outmsgid, const std::string& groupid, const std::string& userid)
{
    std::vector<std::string> uvec;
    uvec.push_back(userid);
    return SndMsgTo(outmsgid, groupid, "grpname", "", (pms::EMsgTag)EMsgTag_Tchat, (pms::EMsgType)EMsgType_Tfbd, (pms::EModuleType)EModuleType_Tlive, (pms::EMsgFlag)EMsgFlag_Fsingle, uvec);
}

int MsgClient::MCNotifySettedMgr(std::string& outmsgid, const std::string& groupid, const std::string& userid)
{
    std::vector<std::string> uvec;
    uvec.push_back(userid);
    return SndMsgTo(outmsgid, groupid, "grpname", "", (pms::EMsgTag)EMsgTag_Tchat, (pms::EMsgType)EMsgType_Tmgr, (pms::EModuleType)EModuleType_Tlive, (pms::EMsgFlag)EMsgFlag_Fsingle, uvec);
}

/////////////////////////////////////////////////
//////////Callback From XMsgCallback/////////////
/////////////////////////////////////////////////

void MsgClient::OnSndMsg(int code, const std::string& msgid)
{
    std::cout << "MsgClient::OnSndMsg msgid:" << msgid << ", code:" << code << std::endl;
    [m_txtMsgDelegate OnSendMessageId:[NSString stringWithCString:msgid.c_str() encoding:NSASCIIStringEncoding] code:code];
}

void MsgClient::OnCmdCallback(int code, int cmd, const std::string& groupid, const MSCbData& data)
{
    NSLog(@"MsgClient::OnCmdCallback cmd:%d, groupid.length:%d, result:%d, seqn:%lld", cmd, groupid.length(), data.result, data.seqn);
    switch (cmd)
    {
        case MSADD_GROUP:
        {
            if (code == 0)
            {
                NSString *nsGrpId = [NSString stringWithCString:groupid.c_str() encoding:NSUTF8StringEncoding];
                NSLog(@"OnCmdCallback add group ok, insert groupid and seqn, toggle callback");
                [m_sqlite3Manager addGroupId:nsGrpId];
                [m_sqlite3Manager addGroupSeqnGrpId:nsGrpId seqn:[NSNumber numberWithLongLong:data.seqn]];
                UpdateLocalSeqn(groupid, data.seqn);
                [m_groupDelegate OnAddGroupSuccessGrpId:nsGrpId];
            } else if (code == -1)
            {
                [m_groupDelegate OnAddGroupFailedGrpId:[[NSString alloc] initWithUTF8String:groupid.c_str()] reason:[[NSString alloc] initWithUTF8String:data.data.c_str()] code:code];
            }
        }
            break;
        case MSRMV_GROUP:
        {
            if (code == 0)
            {
                NSString *nsGrpId = [NSString stringWithCString:groupid.c_str() encoding:NSUTF8StringEncoding];
                NSLog(@"OnCmdCallback del group ok, del groupid and seqn, toggle callback");
                [m_sqlite3Manager delGroupId:nsGrpId];
                RemoveLocalSeqn(groupid);
                [m_groupDelegate OnRmvGroupSuccessGrpId:nsGrpId];
            } else if (code == -1)
            {
                [m_groupDelegate OnRmvGroupFailedGrpId:[[NSString alloc] initWithUTF8String:groupid.c_str()] reason:[[NSString alloc] initWithUTF8String:data.data.c_str()] code:code];
            }
        }
            break;
        case MSFETCH_SEQN:
        {
            if (groupid.length()==0) // for user
            {
                if (data.result==0)
                {
                    UpdateGroupInfoToDb(m_nsUserId, [NSNumber numberWithLongLong:data.seqn], [NSNumber numberWithInt:1]);
                } else if (data.result==-1)
                {
                    UpdateGroupInfoToDb(m_nsUserId, [NSNumber numberWithLongLong:data.seqn], [NSNumber numberWithInt:-1]);
                } else if (data.result==-2)
                {
                    UpdateGroupInfoToDb(m_nsUserId, [NSNumber numberWithLongLong:data.seqn], [NSNumber numberWithInt:-2]);
                }
            } else { // for group
                if (data.result==0)
                {
                    UpdateGroupInfoToDb([NSString stringWithCString:groupid.c_str() encoding:NSUTF8StringEncoding], [NSNumber numberWithLongLong:data.seqn], [NSNumber numberWithInt:1]);
                } else if (data.result==-1)
                {
                    UpdateGroupInfoToDb([NSString stringWithCString:groupid.c_str() encoding:NSUTF8StringEncoding], [NSNumber numberWithLongLong:data.seqn], [NSNumber numberWithInt:-1]);
                } else if (data.result==-2)
                {
                    UpdateGroupInfoToDb([NSString stringWithCString:groupid.c_str() encoding:NSUTF8StringEncoding], [NSNumber numberWithLongLong:data.seqn], [NSNumber numberWithInt:-2]);
                }
            }
        }
            break;
        default:
            break;
    }
}


void MsgClient::OnRecvMsg(int64 seqn, const std::string& msg)
{
    std::cout << "MsgClient::OnRecvMsg was called, seqn:" << seqn << ", msg.length:" << msg.length() << std::endl;
    
    UpdateLocalSeqn(m_strUserId, seqn);
    pms::Entity en;
    en.ParseFromString(msg);
    printf("MsgClient::OnRecvMsg pms::Entity msg tag:%d, cont:%s, romid:%s, usr_from:%s\n"\
           , en.msg_tag()\
           , en.msg_cont().c_str()\
           , en.rom_id().c_str()\
           , en.usr_from().c_str());
    MSTxtMessage *txtMsg = [[MSTxtMessage alloc] init];
    [txtMsg setContent:[NSString stringWithUTF8String:en.msg_cont().c_str()]];
    [txtMsg setFromId:[NSString stringWithUTF8String:en.usr_from().c_str()]];
    [txtMsg setToId:[NSString stringWithUTF8String:en.usr_toto().users(0).c_str()]];
    
    NSDate *dateNow = [NSDate dateWithTimeIntervalSinceNow:(en.msg_time()/1000)];
    NSDate *localeDate = [dateNow  dateByAddingTimeInterval: [[NSTimeZone systemTimeZone] secondsFromGMTForDate:dateNow]];
    [txtMsg setDate:dateNow];
    [txtMsg setTime:localeDate];
    [txtMsg setMillSec:en.msg_time()];
    
    NSLog(@"MsgClient::OnRecvMsg dateNow:%@, localeDate:%@"\
          , dateNow\
          , localeDate);
    
    switch (en.msg_type())
    {
        case pms::EMsgType::TTXT:
        {
            [m_txtMsgDelegate OnRecvTxtMessage:txtMsg];
        }
            break;
        case pms::EMsgType::TFIL:
        {
        }
            break;
        case pms::EMsgType::TPIC:
        {
        }
            break;
        case pms::EMsgType::TAUD:
        {
        }
            break;
        case pms::EMsgType::TVID:
        {
        }
            break;
        case pms::EMsgType::TEMJ:
        {
        }
            break;
        case pms::EMsgType::TSDF:
        {
            [m_txtMsgDelegate OnRecvSelfDefMessage:txtMsg];
        }
            break;
        case pms::EMsgType::TLIV:
        {
            [m_txtMsgDelegate OnNotifyLiveId:[NSString stringWithUTF8String:en.rom_id().c_str()] hostId:[NSString stringWithUTF8String:en.usr_from().c_str()]];
        }
            break;
        case pms::EMsgType::TREN:
        {
            [m_txtMsgDelegate OnNotifyRedEnvelopeGrpId:[NSString stringWithUTF8String:en.rom_id().c_str()] hostId:[NSString stringWithUTF8String:en.usr_from().c_str()]];
        }
            break;
        case pms::EMsgType::TBLK:
        {
            [m_txtMsgDelegate OnNotifyBlacklist:[NSString stringWithUTF8String:en.rom_id().c_str()] userId:[NSString stringWithUTF8String:en.usr_from().c_str()]];
        }
            break;
        case pms::EMsgType::TFBD:
        {
            [m_txtMsgDelegate OnNotifyForbidden:[NSString stringWithUTF8String:en.rom_id().c_str()] userId:[NSString stringWithUTF8String:en.usr_from().c_str()]];
        }
            break;
        case pms::EMsgType::TMGR:
        {
            [m_txtMsgDelegate OnNotifySettedMgrGrpId:[NSString stringWithUTF8String:en.rom_id().c_str()] userId:[NSString stringWithUTF8String:en.usr_from().c_str()]];
        }
            break;
        default:
        {
        }
            break;
    }
    
    
}

void MsgClient::OnRecvGroupMsg(int64 seqn, const std::string& seqnid, const std::string& msg)
{
    std::cout << "MsgClient::OnRecvGroupMsg was called, seqn:" << seqn << ", seqnid:" << seqnid << ", msg.length:" << msg.length() << std::endl;
    
    UpdateLocalSeqn(seqnid, seqn);
    pms::Entity en;
    en.ParseFromString(msg);
    printf("pms::Entity msg tag:%d, cont:%s, romid:%s, usr_from:%s\n"\
           , en.msg_tag()\
           , en.msg_cont().c_str()\
           , en.rom_id().c_str()\
           , en.usr_from().c_str());
    MSTxtMessage *txtMsg = [[MSTxtMessage alloc] init];
    [txtMsg setContent:[NSString stringWithUTF8String:en.msg_cont().c_str()]];
    [txtMsg setFromId:[NSString stringWithUTF8String:en.usr_from().c_str()]];
    [txtMsg setGroupId:[NSString stringWithUTF8String:seqnid.c_str()]];
    
    NSDate *dateNow = [NSDate dateWithTimeIntervalSinceNow:(en.msg_time()/1000)];
    NSDate *localeDate = [dateNow  dateByAddingTimeInterval: [[NSTimeZone systemTimeZone] secondsFromGMTForDate:dateNow]];
    [txtMsg setDate:dateNow];
    [txtMsg setTime:localeDate];
    [txtMsg setMillSec:en.msg_time()];
    
    NSLog(@"MsgClient::OnRecvGroupMsg dateNow:%@, localeDate:%@"\
          , dateNow\
          , localeDate);
    switch (en.msg_type())
    {
        case pms::EMsgType::TTXT:
        {
            [m_txtMsgDelegate OnRecvTxtMessage:txtMsg];
        }
            break;
        case pms::EMsgType::TFIL:
        {
        }
            break;
        case pms::EMsgType::TPIC:
        {
        }
            break;
        case pms::EMsgType::TAUD:
        {
        }
            break;
        case pms::EMsgType::TVID:
        {
        }
            break;
        case pms::EMsgType::TEMJ:
        {
        }
            break;
        case pms::EMsgType::TSDF:
        {
        }
            break;
        case pms::EMsgType::TLIV:
        {
        }
            break;
        case pms::EMsgType::TREN:
        {
        }
            break;
        case pms::EMsgType::TBLK:
        {
        }
            break;
        case pms::EMsgType::TFBD:
        {
        }
            break;
        case pms::EMsgType::TMGR:
        {
        }
            break;
        default:
        {
        }
            break;
    }
    //PutLocalSeqnsToDb();
    
#if 0
    NSError *error = nil;
    Byte *b = (Byte*)malloc(msg.length());
    memset(b, 0x00, msg.length());
    memcpy(b, msg.c_str(), msg.length());
    NSData *ns_dtbyte = [NSData dataWithBytes:b length:msg.length()];
    Entity *entityByte = [Entity parseFromData:ns_dtbyte error:&error];
    if (entityByte == nil)
        NSLog(@"eeeeeeeeeee-->entityByte is nil");
    else
        NSLog(@"eeeeeeeeeee-->entityByte is not nil");
    
    NSString *ns_asc = [[NSString alloc] initWithBytes:msg.c_str() length:msg.length() encoding:NSASCIIStringEncoding];
    NSData *ns_dtt = [ns_asc dataUsingEncoding:NSASCIIStringEncoding];
    Entity *entityMsg = [Entity parseFromData:ns_dtt error:&error];
    Entity *entityMsg0t = [[Entity alloc] initWithData:ns_dtt error:&error];
    if (entityMsg == nil)
        NSLog(@"eeeeeeeeeee-->entityMsg is nil");
    else
        NSLog(@"eeeeeeeeeee-->entityMsg is not nil");
    if (entityMsg0t == nil)
        NSLog(@"eeeeeeeeeee-->entityMsg0t is nil");
    else
        NSLog(@"eeeeeeeeeee-->entityMsg0t is not nil");
    
    NSString *ns_cns = [NSString stringWithCString:msg.c_str() encoding:NSASCIIStringEncoding];
    NSData *ns_dt2 = [ns_cns dataUsingEncoding:NSASCIIStringEncoding];
    Entity* entityMsg2 = [Entity parseFromData:ns_dt2 error:&error];
    if (entityMsg2 == nil)
        NSLog(@"eeeeeeeeeee-->entityMsg2 is nil");
    else
        NSLog(@"eeeeeeeeeee-->entityMsg2 is not nil");
#endif
}

void MsgClient::OnSyncSeqn(int64 maxseqn, int role)
{
    std::cout << "MsgClient::OnSyncSeqn was called maxseqn:" << maxseqn << std::endl;
    //[m_sqlite3Manager addUserId:m_userId];
    //[m_sqlite3Manager updateUserSeqnUserId:m_userId seqn:[NSNumber numberWithLongLong:seqn]];
    
    // if it is sender, this means client send msg, and just get the newmsg's seqn
    // if the new seqn is bigger 1 than cur seqn, it is ok, just update seqn.
    // if the new seqn is bigger 2 or 3 than cur seqn, this need sync data
    // if it is recver, this means client need sync data
    int64 lseqn = GetLocalSeqnFromId(m_strUserId);
    assert(lseqn>0);
    int index = maxseqn - lseqn;
    if (role == EMsgRole_Rsender)
    {
        if (index == 1)
        {
            UpdateLocalSeqn(m_strUserId, maxseqn);
        } else if (index > 1)
        {
            SyncData(lseqn);
        }
    }  else if (role == EMsgRole_Rrecver)
    {
        if (index >0)
        {
            SyncData(lseqn);
        }
    }
}

// get group max seqn
void MsgClient::OnSyncGroupSeqn(const std::string &groupid, int64 maxseqn)
{
    std::cout << "MsgClient::OnSyncGroupSeqn was called groupid:" << groupid << ", maxseqn: " << maxseqn << std::endl;
    //[m_sqlite3Manager updateGroupSeqnGrpId:[NSString stringWithUTF8String:groupid.c_str()] seqn:[NSNumber numberWithLongLong:seqn]];
    // this need sync data
    int64 lseqn = GetLocalSeqnFromId(groupid);
    NSLog(@"MsgClient::OnSyncGroupSeqn ===>seqn seqn:%lld", lseqn);
    assert(lseqn>=0);
    if (maxseqn > lseqn)
        SyncGroupData(groupid, lseqn);
    else{
        NSLog(@"MsgClient::OnSyncGroupSeqn lseqn:%lld, seqn:%lld, you are not in this group:%@", lseqn, maxseqn, [NSString stringWithUTF8String:groupid.c_str()]);
    }
}

// there are new group msg to sync
void MsgClient::OnGroupNotify(int code, const std::string& seqnid)
{
    if (code==0)
    {
        int64 seqn = GetLocalSeqnFromId(seqnid);
        NSLog(@"MsgClient::OnGroupNotify ===>seqn seqn:%lld", seqn);
        if (seqn>0)
            SyncGroupData(seqnid, seqn);
        else
        {
            NSLog(@"MsgClient::OnGroupNotify !!!!!seqn:%lld, not find seqnid:%@, you're not in this group", seqn, [NSString stringWithUTF8String:seqnid.c_str()]);
            //assert(seqn>0);
        }
    } else {
        NSLog(@"MsgClient::OnGroupNotify error code is :%d!!!", code);
    }
}

void MsgClient::OnNotifySeqn(int code, const std::string& seqnid)
{
    if (code==0)
    {
        if (seqnid.length()>0)
        {
            NSLog(@"THIS SHOULD NOT BE HAPPEND HERE, seqnid:%@", [NSString stringWithUTF8String:seqnid.c_str()]);
            //int64 seqn = GetLocalSeqnFromId(seqnid);
            //if (seqn>0)
            //    SyncGroupSeqn(seqnid, seqn, (pms::EMsgRole)EMsgRole_Rsender);
            //else
            //    assert(seqn>0);
        } else if (seqnid.length()==0) // this means userid
        {
            int64 lseqn = GetLocalSeqnFromId(m_strUserId);
            assert(lseqn>0);
            SyncSeqn(lseqn, (pms::EMsgRole)EMsgRole_Rsender);
        }
    } else {
        NSLog(@"MsgClient::OnGroupSeqn error code is :%d!!!", code);
    }
}

void MsgClient::OnNotifyData(int code, const std::string& seqnid)
{
    if (code==0)
    {
        if (seqnid.length()>0)
        {
            int64 seqn = GetLocalSeqnFromId(seqnid);
            NSLog(@"MsgClient::OnNotifyData ===>seqn seqn:%lld", seqn);
            if (seqn>0)
                SyncGroupData(seqnid, seqn);
            else
            {
                NSLog(@"MsgClient::OnNotifyData seqn:%lld, you're not in this group:%@", seqn, [NSString stringWithUTF8String:seqnid.c_str()]);
            }
        } else if (seqnid.length()==0) // this means userid
        {
            NSLog(@"MsgClient::OnNotifyData notify user to sync data!!!");
            int64 lseqn = GetLocalSeqnFromId(m_strUserId);
            assert(lseqn>0);
            SyncData(lseqn);
        }
    } else {
        NSLog(@"MsgClient::OnGroupNotify error code is :%d!!!", code);
    }
}



void MsgClient::OnMsgServerConnected()
{
    std::cout << "MsgClient::OnMsgServerConnected was called, fetchallseqn once" << std::endl;
    FetchAllSeqns();
    [m_clientDelegate OnMsgServerConnected];
    [m_clientDelegate OnMsgClientInitializing];
    
    // check per second until get all fetch
    NSTimeInterval period = 1.0; //设置时间间隔
    //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        NSLog(@"MsgClient::OnMsgServerConnected timer was called...............");
        //在这里执行事件
        if (IsFetchedAll())
        {
            // stop timer here
            m_isFetched = true;
            [m_clientDelegate OnMsgClientInitialized];
            dispatch_source_set_cancel_handler(_timer, ^{
               
                NSLog(@"MsgClient::OnMsgServerConnected dispatch_source_cancel...ok");
            });
            dispatch_source_cancel(_timer);
        } else {
            FetchAllSeqns();
        }
    });
    dispatch_resume(_timer);
}


void MsgClient::OnMsgServerConnecting()
{
    //std::cout << "MsgClient::OnMsgServerConnecting was called" << std::endl;
    [m_clientDelegate OnMsgServerConnecting];
}

void MsgClient::OnMsgServerDisconnect()
{
    //std::cout << "MsgClient::OnMsgServerDisconnect was called" << std::endl;
    [m_clientDelegate OnMsgServerDisconnect];
}

void MsgClient::OnMsgServerConnectionFailure()
{
    //std::cout << "MsgClient::OnMsgServerConnectionFailer was called" << std::endl;
    [m_clientDelegate OnMsgServerConnectionFailure];
}
