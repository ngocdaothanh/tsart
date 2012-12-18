MAC_ADDR=$(ifconfig eth0 | sed -n 's/.*HWaddr \([a-f0-9:]*\).*/\1/p')
IP=($(curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC_ADDR/local-ipv4s))
for ip in ${IP[@]:1}; do
    echo "Adding IP: $ip"
    sudo ip addr add dev eth0 $ip/24
done

ip addr show
