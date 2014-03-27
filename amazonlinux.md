#Setup tsung for AmazonLinux

This is a note for setup erlang-R16B03-1 and Tsung-1.5.0 on AmazonLinux.

Reference -> http://www.slideshare.net/ngocdaothanh/tsung-13985127 (Tsung 1.4.2)

## Instance setting

* Type: m1.large
* SecurityGroup: Arrow TCP 0-65535

---------
## For OS setup

Install gcc
`sudo yum install gcc`

Edit `/etc/security/limits.conf`
`sudo vim /etc/security/limits.conf`

	*  soft  nofile  1024000
	*  hard  nofile  1024000

Logout once and check
`logout`
`ulimit -n`

Edit `/etc/sysctl.conf`

`sudo vim /etc/sysctl.conf`

	# General gigabit tuning
	net.core.rmem_max = 16777216
	net.core.wmem_max = 16777216
	net.ipv4.tcp_rmem = 4096 87380 16777216
	net.ipv4.tcp_wmem = 4096 65536 16777216

	# This gives the kernel more memory for TCP
	# which you need with many (100k+) open socket connections
	net.ipv4.tcp_mem = 50576 64768 98152

	# Backlog
	net.core.netdev_max_backlog = 2048
	net.core.somaxconn = 1024
	net.ipv4.tcp_max_syn_backlog = 2048
	net.ipv4.tcp_syncookies = 1

`sudo sysctl -p`

---------
## Install Erlang

`mkdir ~/opt`

`sudo yum install ncurses-devel`

`sudo yum install openssl-devel`

`wget http://www.erlang.org/download/otp_src_R16B03-1.tar.gz`

`tar xzf otp_src_R16B03-1.tar.gz`

`cd otp_src_R16B03-1`

`./configure --prefix=$HOME/opt/erlang-R16B03-1`

`make install`

`sudo echo 'pathmunge /home/ec2-user/opt/erlang-R16B03-1/bin' > /etc/profile.d/erlang.sh`

`sudo chmod +x /etc/profile.d/erlang.sh`

---------
## Install Tsung

`wget http://tsung.erlang-projects.org/dist/tsung-1.5.0.tar.gz`

`tar xzf tsung-1.5.0.tar.gz`

`cd tsung-1.5.0`

`./configure --prefix=$HOME/opt/tsung-1.5.0`

`make install`

### For Reporting

`sudo yum install numpy`

`sudo yum install scipy`

`sudo yum install python-matplotlib`

`sudo yum install gnuplot`

`sudo yum install perl-CPAN`

`sudo cpan Template`

---
### For ssh login

From local PC
`scp -i XXXX.key XXXX.key ec2-user@host:/home/user/ec2-user/.ssh/`

From ec2 instance
`mv ~/.ssh/XXXXX.key ~/.ssh/id.rsa`
`ssh localhost erl`
`exit`

---------
## Start Tsung test

`~/opt/tsung-1.5.0/bin/tsung -f t1.xml start`

`~/opt/tsung-1.5.0/bin/tsung -f status`

### Reporting

Create html report
`~/opt/tsung-1.5.0/lib/tsung/bin/tsung_stats.pl`

Create only png files
`~/opt/tsung-1.5.0/bin/tsplot "first" tsung.log  -d ~/outputdir`

Start simple http server
`python -m SimpleHTTPServer`

---------
## For distributed test

Create AMI and use it to launch new instances.

Enable distributed clients

http://tsung.erlang-projects.org/user_manual/faq.html#can-t-start-distributed-clients-timeout-error

Disable firewall
`sudo chkconfig iptables off`
`sudo /etc/init.d/iptables stop`

Edit `/etc/hosts`
`sudo vim /etc/hosts`

	127.0.0.1   localhost localhost.localdomain
	<tsung1_Private_IP> tsung1
	<tsung2_Private_IP> tsung2
	<tsung3_Private_IP> tsung3

Confirm ssh

`ssh tsung1 erl`
`exit`
`ssh tsung2 erl`
`exit`
`ssh tsung3 erl`
`exit`
`ssh localhost erl`
`exit`

Confirm distributed clients

	erl -rsh ssh -sname foo -setcookie mycookie
	Eshell V5.4.3 (abort with ^G)
	(foo@tsung1)1>slave:start(tsung2,bar,"-setcookie mycookie").
	{ok,bar@tsung2}