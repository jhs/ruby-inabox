$out ||= $stdout

# workaround for NetBSD, OpenBSD and etc.
$out.puts("#define pseudo_AF_FTIP pseudo_AF_RTIP")

# skip empty lines and comment lines
DATA.each_line do |s|
  name, value = s.scan(/\S+/)
  if name && name[0] != ?#
    if name =~ /\AINADDR_/
      define = "sock_define_uconst"
    else
      define = "sock_define_const"
    end
    $out.puts("#ifdef #{name}")
    $out.puts("    #{define}(\"#{name}\", #{name});")
    if value
    $out.puts("#else")
    $out.puts("    #{define}(\"#{name}\", #{value});")
    end
    $out.puts("#endif")
    $out.puts
  end
end

__END__

SOCK_STREAM
SOCK_DGRAM
SOCK_RAW
SOCK_RDM
SOCK_SEQPACKET
SOCK_PACKET

AF_INET
PF_INET
AF_UNIX
PF_UNIX
AF_AX25
PF_AX25
AF_IPX
PF_IPX
AF_APPLETALK
PF_APPLETALK
AF_UNSPEC
PF_UNSPEC
AF_LOCAL
PF_LOCAL
AF_IMPLINK
PF_IMPLINK
AF_PUP
PF_PUP
AF_CHAOS
PF_CHAOS
AF_NS
PF_NS
AF_ISO
PF_ISO
AF_OSI
PF_OSI
AF_ECMA
PF_ECMA
AF_DATAKIT
PF_DATAKIT
AF_CCITT
PF_CCITT
AF_SNA
PF_SNA
AF_DEC
PF_DEC
AF_DLI
PF_DLI
AF_LAT
PF_LAT
AF_HYLINK
PF_HYLINK
AF_ROUTE
PF_ROUTE
AF_LINK
PF_LINK
AF_COIP
PF_COIP
AF_CNT
PF_CNT
AF_SIP
PF_SIP
AF_NDRV
PF_NDRV
AF_ISDN
PF_ISDN
AF_NATM
PF_NATM
AF_SYSTEM
PF_SYSTEM
AF_NETBIOS
PF_NETBIOS
AF_PPP
PF_PPP
AF_ATM
PF_ATM
AF_NETGRAPH
PF_NETGRAPH
AF_MAX
PF_MAX

AF_E164
PF_XTP
PF_RTIP
PF_PIP
PF_KEY

MSG_OOB
MSG_PEEK
MSG_DONTROUTE
MSG_EOR
MSG_TRUNC
MSG_CTRUNC
MSG_WAITALL
MSG_DONTWAIT
MSG_EOF
MSG_FLUSH
MSG_HOLD
MSG_SEND
MSG_HAVEMORE
MSG_RCVMORE
MSG_COMPAT

SOL_SOCKET
SOL_IP
SOL_IPX
SOL_AX25
SOL_ATALK
SOL_TCP
SOL_UDP

IPPROTO_IP	0
IPPROTO_ICMP	1
IPPROTO_IGMP
IPPROTO_GGP
IPPROTO_TCP	6
IPPROTO_EGP
IPPROTO_PUP
IPPROTO_UDP	17
IPPROTO_IDP
IPPROTO_HELLO
IPPROTO_ND
IPPROTO_TP
IPPROTO_XTP
IPPROTO_EON
IPPROTO_BIP
IPPROTO_AH
IPPROTO_DSTOPTS
IPPROTO_ESP
IPPROTO_FRAGMENT
IPPROTO_HOPOPTS
IPPROTO_ICMPV6
IPPROTO_IPV6
IPPROTO_NONE
IPPROTO_ROUTING

IPPROTO_RAW	255
IPPROTO_MAX

# Some port configuration
IPPORT_RESERVED		1024
IPPORT_USERRESERVED	5000

# Some reserved IP v.4 addresses
INADDR_ANY		0x00000000
INADDR_BROADCAST	0xffffffff
INADDR_LOOPBACK		0x7F000001
INADDR_UNSPEC_GROUP	0xe0000000
INADDR_ALLHOSTS_GROUP	0xe0000001
INADDR_MAX_LOCAL_GROUP	0xe00000ff
INADDR_NONE		0xffffffff

# IP [gs]etsockopt options
IP_OPTIONS
IP_HDRINCL
IP_TOS
IP_TTL
IP_RECVOPTS
IP_RECVRETOPTS
IP_RECVDSTADDR
IP_RETOPTS
IP_MULTICAST_IF
IP_MULTICAST_TTL
IP_MULTICAST_LOOP
IP_ADD_MEMBERSHIP
IP_DROP_MEMBERSHIP
IP_DEFAULT_MULTICAST_TTL
IP_DEFAULT_MULTICAST_LOOP
IP_MAX_MEMBERSHIPS

SO_DEBUG
SO_REUSEADDR
SO_REUSEPORT
SO_TYPE
SO_ERROR
SO_DONTROUTE
SO_BROADCAST
SO_SNDBUF
SO_RCVBUF
SO_KEEPALIVE
SO_OOBINLINE
SO_NO_CHECK
SO_PRIORITY
SO_LINGER
SO_PASSCRED
SO_PEERCRED
SO_RCVLOWAT
SO_SNDLOWAT
SO_RCVTIMEO
SO_SNDTIMEO
SO_ACCEPTCONN
SO_USELOOPBACK
SO_ACCEPTFILTER
SO_DONTTRUNC
SO_WANTMORE
SO_WANTOOBFLAG
SO_NREAD
SO_NKE
SO_NOSIGPIPE
SO_SECURITY_AUTHENTICATION
SO_SECURITY_ENCRYPTION_TRANSPORT
SO_SECURITY_ENCRYPTION_NETWORK
SO_BINDTODEVICE
SO_ATTACH_FILTER
SO_DETACH_FILTER
SO_PEERNAME
SO_TIMESTAMP

SOPRI_INTERACTIVE
SOPRI_NORMAL
SOPRI_BACKGROUND

IPX_TYPE

TCP_NODELAY
TCP_MAXSEG

EAI_ADDRFAMILY
EAI_AGAIN
EAI_BADFLAGS
EAI_FAIL
EAI_FAMILY
EAI_MEMORY
EAI_NODATA
EAI_NONAME
EAI_OVERFLOW
EAI_SERVICE
EAI_SOCKTYPE
EAI_SYSTEM
EAI_BADHINTS
EAI_PROTOCOL
EAI_MAX

AI_PASSIVE
AI_CANONNAME
AI_NUMERICHOST
AI_NUMERICSERV
AI_MASK
AI_ALL
AI_V4MAPPED_CFG
AI_ADDRCONFIG
AI_V4MAPPED
AI_DEFAULT

NI_MAXHOST
NI_MAXSERV
NI_NOFQDN
NI_NUMERICHOST
NI_NAMEREQD
NI_NUMERICSERV
NI_DGRAM

SHUT_RD		0
SHUT_WR		1
SHUT_RDWR	2

IPV6_JOIN_GROUP
IPV6_LEAVE_GROUP
IPV6_MULTICAST_HOPS
IPV6_MULTICAST_IF
IPV6_MULTICAST_LOOP
IPV6_UNICAST_HOPS
IPV6_V6ONLY
IPV6_CHECKSUM
IPV6_DONTFRAG
IPV6_DSTOPTS
IPV6_HOPLIMIT
IPV6_HOPOPTS
IPV6_NEXTHOP
IPV6_PATHMTU
IPV6_PKTINFO
IPV6_RECVDSTOPTS
IPV6_RECVHOPLIMIT
IPV6_RECVHOPOPTS
IPV6_RECVPKTINFO
IPV6_RECVRTHDR
IPV6_RECVTCLASS
IPV6_RTHDR
IPV6_RTHDRDSTOPTS
IPV6_RTHDR_TYPE_0
IPV6_RECVPATHMTU
IPV6_TCLASS
IPV6_USE_MIN_MTU

INET_ADDRSTRLEN
INET6_ADDRSTRLEN
