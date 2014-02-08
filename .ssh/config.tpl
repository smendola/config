Host kando
    Hostname        engvmkando
    Port            29418

Host skytap
	HostName		services-useast.skytap.com
	StrictHostKeyChecking	no
	CheckHostIP		no
#	UserKnownHostsFile	/dev/null
	User			ops
	IdentityFile	~/.ssh/id_skytap
	Port {{SKY_PORT}}

Host skytun
	HostName		services-useast.skytap.com
	StrictHostKeyChecking	no
#	UserKnownHostsFile	/dev/null
	CheckHostIP		no
	User			ops
	IdentityFile	~/.ssh/id_skytap
	LocalForward	10080	localhost:80
	LocalForward	10443	localhost:443
	LocalForward	12080	localhost:2080
	LocalForward	12443	localhost:2443
	LocalForward	18080	localhost:8080
	LocalForward	18081	localhost:8081
	LocalForward	19000	localhost:9000
	LocalForward	10873	localhost:873
	# This helps with PuTTY, which doesn't read .ssh/conf
	# we give it a fixed port number to connect to
	LocalForward	8022	localhost:22
	DynamicForward 	1080
	ForwardX11		yes
	ForwardX11Trusted	yes
	Port {{SKY_PORT}}
