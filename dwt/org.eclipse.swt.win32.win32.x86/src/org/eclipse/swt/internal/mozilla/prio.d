module org.eclipse.swt.internal.mozilla.prio;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.prtime;
import org.eclipse.swt.internal.mozilla.prinrval;

extern (System):

alias PRIntn PRDescIdentity;
alias void   PRFilePrivate;

struct PRFileDesc
{
    PRIOMethods *methods;
    PRFilePrivate *secret;
    PRFileDesc *lower;
    PRFileDesc *higher;
    void  function(PRFileDesc *fd)dtor;
    PRDescIdentity identity;
}

enum PRTransmitFileFlags
{
    PR_TRANSMITFILE_KEEP_OPEN,
    PR_TRANSMITFILE_CLOSE_SOCKET,
}

const PR_AF_INET = 2;
const PR_AF_LOCAL = 1;
const PR_INADDR_LOOPBACK = 0x7f000001;
const PR_AF_UNSPEC = 0;

union _N2
{
    PRUint8 [16]_S6_u8;
    PRUint16 [8]_S6_u16;
    PRUint32 [4]_S6_u32;
    PRUint64 [2]_S6_u64;
}

struct PRIPv6Addr
{
	struct _N2{
		union
		{
			PRUint8 [16]_S6_u8;
			PRUint16 [8]_S6_u16;
			PRUint32 [4]_S6_u32;
			PRUint64 [2]_S6_u64;
		}
	}
	_N2 _S6_un;
}

struct _N3
{
    PRUint16 family;
    char [14]data;
}

struct _N4
{
    PRUint16 family;
    PRUint16 port;
    PRUint32 ip;
    char [8]pad;
}

struct _N5
{
    PRUint16 family;
    PRUint16 port;
    PRUint32 flowinfo;
    PRIPv6Addr ip;
    PRUint32 scope_id;
}

union PRNetAddr
{
    struct _N3
    {
        PRUint16 family;
        char [14]data;
    }
    _N3 raw;
    struct _N4
    {
        PRUint16 family;
        PRUint16 port;
        PRUint32 ip;
        char [8]pad;
    }
    _N4 inet;
    struct _N5
    {
        PRUint16 family;
        PRUint16 port;
        PRUint32 flowinfo;
        PRIPv6Addr ip;
        PRUint32 scope_id;
    }
    _N5 ipv6;
}

enum PRSockOption
{
    PR_SockOpt_Nonblocking,
    PR_SockOpt_Linger,
    PR_SockOpt_Reuseaddr,
    PR_SockOpt_Keepalive,
    PR_SockOpt_RecvBufferSize,
    PR_SockOpt_SendBufferSize,
    PR_SockOpt_IpTimeToLive,
    PR_SockOpt_IpTypeOfService,
    PR_SockOpt_AddMember,
    PR_SockOpt_DropMember,
    PR_SockOpt_McastInterface,
    PR_SockOpt_McastTimeToLive,
    PR_SockOpt_McastLoopback,
    PR_SockOpt_NoDelay,
    PR_SockOpt_MaxSegment,
    PR_SockOpt_Broadcast,
    PR_SockOpt_Last,
}

struct PRLinger
{
    PRBool polarity;
    PRIntervalTime linger;
}

struct PRMcastRequest
{
    PRNetAddr mcaddr;
    PRNetAddr ifaddr;
}

union _N6
{
    PRUintn ip_ttl;
    PRUintn mcast_ttl;
    PRUintn tos;
    PRBool non_blocking;
    PRBool reuse_addr;
    PRBool keep_alive;
    PRBool mcast_loopback;
    PRBool no_delay;
    PRBool broadcast;
    PRSize max_segment;
    PRSize recv_buffer_size;
    PRSize send_buffer_size;
    PRLinger linger;
    PRMcastRequest add_member;
    PRMcastRequest drop_member;
    PRNetAddr mcast_if;
}

struct PRSocketOptionData
{
    int option;
    union _N6
    {
        PRUintn ip_ttl;
        PRUintn mcast_ttl;
        PRUintn tos;
        PRBool non_blocking;
        PRBool reuse_addr;
        PRBool keep_alive;
        PRBool mcast_loopback;
        PRBool no_delay;
        PRBool broadcast;
        PRSize max_segment;
        PRSize recv_buffer_size;
        PRSize send_buffer_size;
        PRLinger linger;
        PRMcastRequest add_member;
        PRMcastRequest drop_member;
        PRNetAddr mcast_if;
    }
    _N6 value;
}

struct PRIOVec
{
    char *iov_base;
    int iov_len;
}

enum PRDescType
{
    PR_DESC_FILE = 1,
    PR_DESC_SOCKET_TCP,
    PR_DESC_SOCKET_UDP,
    PR_DESC_LAYERED,
    PR_DESC_PIPE,
}

enum PRSeekWhence
{
    PR_SEEK_SET,
    PR_SEEK_CUR,
    PR_SEEK_END,
}

version(NON_XPCOM_GLUE){
    int  PR_GetDescType(PRFileDesc *file);
}

alias PRStatus  function(PRFileDesc *fd)PRCloseFN;
alias PRInt32  function(PRFileDesc *fd, void *buf, PRInt32 amount)PRReadFN;
alias PRInt32  function(PRFileDesc *fd, void *buf, PRInt32 amount)PRWriteFN;
alias PRInt32  function(PRFileDesc *fd)PRAvailableFN;
alias PRInt64  function(PRFileDesc *fd)PRAvailable64FN;
alias PRStatus  function(PRFileDesc *fd)PRFsyncFN;
alias PROffset32  function(PRFileDesc *fd, PROffset32 offset, int how)PRSeekFN;
alias PROffset64  function(PRFileDesc *fd, PROffset64 offset, int how)PRSeek64FN;
alias PRStatus  function(PRFileDesc *fd, PRFileInfo *info)PRFileInfoFN;
alias PRStatus  function(PRFileDesc *fd, PRFileInfo64 *info)PRFileInfo64FN;
alias PRInt32  function(PRFileDesc *fd, PRIOVec *iov, PRInt32 iov_size, PRIntervalTime timeout)PRWritevFN;
alias PRStatus  function(PRFileDesc *fd, PRNetAddr *addr, PRIntervalTime timeout)PRConnectFN;
alias PRFileDesc * function(PRFileDesc *fd, PRNetAddr *addr, PRIntervalTime timeout)PRAcceptFN;
alias PRStatus  function(PRFileDesc *fd, PRNetAddr *addr)PRBindFN;
alias PRStatus  function(PRFileDesc *fd, PRIntn backlog)PRListenFN;
alias PRStatus  function(PRFileDesc *fd, PRIntn how)PRShutdownFN;
alias PRInt32  function(PRFileDesc *fd, void *buf, PRInt32 amount, PRIntn flags, PRIntervalTime timeout)PRRecvFN;
alias PRInt32  function(PRFileDesc *fd, void *buf, PRInt32 amount, PRIntn flags, PRIntervalTime timeout)PRSendFN;
alias PRInt32  function(PRFileDesc *fd, void *buf, PRInt32 amount, PRIntn flags, PRNetAddr *addr, PRIntervalTime timeout)PRRecvfromFN;
alias PRInt32  function(PRFileDesc *fd, void *buf, PRInt32 amount, PRIntn flags, PRNetAddr *addr, PRIntervalTime timeout)PRSendtoFN;
alias PRInt16  function(PRFileDesc *fd, PRInt16 in_flags, PRInt16 *out_flags)PRPollFN;
alias PRInt32  function(PRFileDesc *sd, PRFileDesc **nd, PRNetAddr **raddr, void *buf, PRInt32 amount, PRIntervalTime t)PRAcceptreadFN;
alias PRInt32  function(PRFileDesc *sd, PRFileDesc *fd, void *headers, PRInt32 hlen, int flags, PRIntervalTime t)PRTransmitfileFN;
alias PRStatus  function(PRFileDesc *fd, PRNetAddr *addr)PRGetsocknameFN;
alias PRStatus  function(PRFileDesc *fd, PRNetAddr *addr)PRGetpeernameFN;
alias PRStatus  function(PRFileDesc *fd, PRSocketOptionData *data)PRGetsocketoptionFN;
alias PRStatus  function(PRFileDesc *fd, PRSocketOptionData *data)PRSetsocketoptionFN;
alias PRInt32  function(PRFileDesc *networkSocket, PRSendFileData *sendData, int flags, PRIntervalTime timeout)PRSendfileFN;
alias PRStatus  function(PRFileDesc *fd, PRInt16 out_flags)PRConnectcontinueFN;
alias PRIntn  function(PRFileDesc *fd)PRReservedFN;

struct PRIOMethods
{
    int file_type;
    PRCloseFN close;
    PRReadFN read;
    PRWriteFN write;
    PRAvailableFN available;
    PRAvailable64FN available64;
    PRFsyncFN fsync;
    PRSeekFN seek;
    PRSeek64FN seek64;
    PRFileInfoFN fileInfo;
    PRFileInfo64FN fileInfo64;
    PRWritevFN writev;
    PRConnectFN connect;
    PRAcceptFN accept;
    PRBindFN bind;
    PRListenFN listen;
    PRShutdownFN shutdown;
    PRRecvFN recv;
    PRSendFN send;
    PRRecvfromFN recvfrom;
    PRSendtoFN sendto;
    PRPollFN poll;
    PRAcceptreadFN acceptread;
    PRTransmitfileFN transmitfile;
    PRGetsocknameFN getsockname;
    PRGetpeernameFN getpeername;
    PRReservedFN reserved_fn_6;
    PRReservedFN reserved_fn_5;
    PRGetsocketoptionFN getsocketoption;
    PRSetsocketoptionFN setsocketoption;
    PRSendfileFN sendfile;
    PRConnectcontinueFN connectcontinue;
    PRReservedFN reserved_fn_3;
    PRReservedFN reserved_fn_2;
    PRReservedFN reserved_fn_1;
    PRReservedFN reserved_fn_0;
}

enum PRSpecialFD
{
    PR_StandardInput,
    PR_StandardOutput,
    PR_StandardError,
}

version(NON_XPCOM_GLUE)
{
    PRFileDesc *    PR_GetSpecialFD(int id);
    PRDescIdentity  PR_GetUniqueIdentity(char *layer_name);
    char *          PR_GetNameForIdentity(PRDescIdentity ident);
    PRDescIdentity  PR_GetLayersIdentity(PRFileDesc *fd);
    PRFileDesc *    PR_GetIdentitiesLayer(PRFileDesc *fd_stack, PRDescIdentity id);
    PRIOMethods *   PR_GetDefaultIOMethods();
    PRFileDesc *    PR_CreateIOLayerStub(PRDescIdentity ident, PRIOMethods *methods);
    PRFileDesc *    PR_CreateIOLayer(PRFileDesc *fd);
    PRStatus        PR_PushIOLayer(PRFileDesc *fd_stack, PRDescIdentity id, PRFileDesc *layer);
    PRFileDesc *    PR_PopIOLayer(PRFileDesc *fd_stack, PRDescIdentity id);
}

const PR_RDONLY = 0x01;
const PR_WRONLY = 0x02;
const PR_RDWR = 0x04;
const PR_CREATE_FILE = 0x08;
const PR_APPEND = 0x10;
const PR_TRUNCATE = 0x20;
const PR_SYNC = 0x40;
const PR_EXCL = 0x80;

version(NON_XPCOM_GLUE) {
    PRFileDesc * PR_Open(char *name, PRIntn flags, PRIntn mode);
}

const PR_IRWXU = 00700;
const PR_IRUSR = 00400;
const PR_IWUSR = 00200;
const PR_IXUSR = 00100;
const PR_IRWXG = 00070;
const PR_IRGRP = 00040;
const PR_IWGRP = 00020;
const PR_IXGRP = 00010;
const PR_IRWXO = 00007;
const PR_IROTH = 00004;
const PR_IWOTH = 00002;
const PR_IXOTH = 00001;

version(NON_XPCOM_GLUE)
{
    PRFileDesc *    PR_OpenFile(char *name, PRIntn flags, PRIntn mode);
    PRStatus        PR_Close(PRFileDesc *fd);
    PRInt32         PR_Read(PRFileDesc *fd, void *buf, PRInt32 amount);
    PRInt32         PR_Write(PRFileDesc *fd, void *buf, PRInt32 amount);
}

const PR_MAX_IOVECTOR_SIZE = 16;

version(NON_XPCOM_GLUE)
{
    PRInt32     PR_Writev(PRFileDesc *fd, PRIOVec *iov, PRInt32 iov_size, PRIntervalTime timeout);
    PRStatus    PR_Delete(char *name);
}

enum PRFileType
{
    PR_FILE_FILE = 1,
    PR_FILE_DIRECTORY,
    PR_FILE_OTHER,
}

struct PRFileInfo
{
    int type;
    PROffset32 size;
    PRTime creationTime;
    PRTime modifyTime;
}

struct PRFileInfo64
{
    int type;
    PROffset64 size;
    PRTime creationTime;
    PRTime modifyTime;
}

version (NON_XPCOM_GLUE)
{
    PRStatus  PR_GetFileInfo(char *fn, PRFileInfo *info);
    PRStatus  PR_GetFileInfo64(char *fn, PRFileInfo64 *info);
    PRStatus  PR_GetOpenFileInfo(PRFileDesc *fd, PRFileInfo *info);
    PRStatus  PR_GetOpenFileInfo64(PRFileDesc *fd, PRFileInfo64 *info);
    PRStatus  PR_Rename(char *from, char *to);
}

enum PRAccessHow
{
    PR_ACCESS_EXISTS = 1,
    PR_ACCESS_WRITE_OK,
    PR_ACCESS_READ_OK,
}

version(NON_XPCOM_GLUE)
{
    PRStatus    PR_Access(char *name, int how);
    PROffset32  PR_Seek(PRFileDesc *fd, PROffset32 offset, int whence);
    PROffset64  PR_Seek64(PRFileDesc *fd, PROffset64 offset, int whence);
    PRInt32     PR_Available(PRFileDesc *fd);
    PRInt64     PR_Available64(PRFileDesc *fd);
    PRStatus    PR_Sync(PRFileDesc *fd);
}

struct PRDirEntry
{
    char *name;
}

alias void PRDir;

version(NON_XPCOM_GLUE) {
    PRDir * PR_OpenDir(char *name);
}

enum PRDirFlags
{
    PR_SKIP_NONE,
    PR_SKIP_DOT,
    PR_SKIP_DOT_DOT,
    PR_SKIP_BOTH,
    PR_SKIP_HIDDEN,
}

version(NON_XPCOM_GLUE)
{
    PRDirEntry *    PR_ReadDir(PRDir *dir, int flags);
    PRStatus        PR_CloseDir(PRDir *dir);
    PRStatus        PR_MkDir(char *name, PRIntn mode);
    PRStatus        PR_MakeDir(char *name, PRIntn mode);
    PRStatus        PR_RmDir(char *name);
    PRFileDesc *    PR_NewUDPSocket();
    PRFileDesc *    PR_NewTCPSocket();
    PRFileDesc *    PR_OpenUDPSocket(PRIntn af);
    PRFileDesc *    PR_OpenTCPSocket(PRIntn af);
    PRStatus        PR_Connect(PRFileDesc *fd, PRNetAddr *addr, PRIntervalTime timeout);
    PRStatus        PR_ConnectContinue(PRFileDesc *fd, PRInt16 out_flags);
    PRStatus        PR_GetConnectStatus(PRPollDesc *pd);
    PRFileDesc *    PR_Accept(PRFileDesc *fd, PRNetAddr *addr, PRIntervalTime timeout);
    PRStatus        PR_Bind(PRFileDesc *fd, PRNetAddr *addr);
    PRStatus        PR_Listen(PRFileDesc *fd, PRIntn backlog);
}

enum PRShutdownHow
{
    PR_SHUTDOWN_RCV,
    PR_SHUTDOWN_SEND,
    PR_SHUTDOWN_BOTH,
}

version(NON_XPCOM_GLUE) {
    PRStatus  PR_Shutdown(PRFileDesc *fd, int how);
}

const PR_MSG_PEEK = 0x2;

version(NON_XPCOM_GLUE)
{
    PRInt32  PR_Recv(PRFileDesc *fd, void *buf, PRInt32 amount, PRIntn flags, PRIntervalTime timeout);
    PRInt32  PR_Send(PRFileDesc *fd, void *buf, PRInt32 amount, PRIntn flags, PRIntervalTime timeout);
    PRInt32  PR_RecvFrom(PRFileDesc *fd, void *buf, PRInt32 amount, PRIntn flags, PRNetAddr *addr, PRIntervalTime timeout);
    PRInt32  PR_SendTo(PRFileDesc *fd, void *buf, PRInt32 amount, PRIntn flags, PRNetAddr *addr, PRIntervalTime timeout);
    PRInt32  PR_TransmitFile(PRFileDesc *networkSocket, PRFileDesc *sourceFile, void *headers, PRInt32 hlen, int flags, PRIntervalTime timeout);
}

struct PRSendFileData
{
    PRFileDesc *fd;
    PRUint32 file_offset;
    PRSize file_nbytes;
    void *header;
    PRInt32 hlen;
    void *trailer;
    PRInt32 tlen;
}

version(NON_XPCOM_GLUE)
{
    PRInt32   PR_SendFile(PRFileDesc *networkSocket, PRSendFileData *sendData, int flags, PRIntervalTime timeout);
    PRInt32   PR_AcceptRead(PRFileDesc *listenSock, PRFileDesc **acceptedSock, PRNetAddr **peerAddr, void *buf, PRInt32 amount, PRIntervalTime timeout);
    PRStatus  PR_NewTCPSocketPair(PRFileDesc **fds);
    PRStatus  PR_GetSockName(PRFileDesc *fd, PRNetAddr *addr);
    PRStatus  PR_GetPeerName(PRFileDesc *fd, PRNetAddr *addr);
    PRStatus  PR_GetSocketOption(PRFileDesc *fd, PRSocketOptionData *data);
    PRStatus  PR_SetSocketOption(PRFileDesc *fd, PRSocketOptionData *data);
    PRStatus  PR_SetFDInheritable(PRFileDesc *fd, PRBool inheritable);
    PRFileDesc * PR_GetInheritedFD(char *name);
}

enum PRFileMapProtect
{
    PR_PROT_READONLY,
    PR_PROT_READWRITE,
    PR_PROT_WRITECOPY,
}

alias void PRFileMap;

version(NON_XPCOM_GLUE)
{
    PRFileMap * PR_CreateFileMap(PRFileDesc *fd, PRInt64 size, int prot);
    PRInt32     PR_GetMemMapAlignment();
    void *      PR_MemMap(PRFileMap *fmap, PROffset64 offset, PRUint32 len);
    PRStatus    PR_MemUnmap(void *addr, PRUint32 len);
    PRStatus    PR_CloseFileMap(PRFileMap *fmap);
    PRStatus    PR_CreatePipe(PRFileDesc **readPipe, PRFileDesc **writePipe);
}

struct PRPollDesc
{
    PRFileDesc *fd;
    PRInt16 in_flags;
    PRInt16 out_flags;
}

const PR_POLL_READ = 0x1;
const PR_POLL_WRITE = 0x2;
const PR_POLL_EXCEPT = 0x4;
const PR_POLL_ERR = 0x8;
const PR_POLL_NVAL = 0x10;
const PR_POLL_HUP = 0x20;

version(NON_XPCOM_GLUE)
{
    PRInt32  PR_Poll(PRPollDesc *pds, PRIntn npds, PRIntervalTime timeout);
    PRFileDesc * PR_NewPollableEvent();
    PRStatus  PR_DestroyPollableEvent(PRFileDesc *event);
    PRStatus  PR_SetPollableEvent(PRFileDesc *event);
    PRStatus  PR_WaitForPollableEvent(PRFileDesc *event);
}
