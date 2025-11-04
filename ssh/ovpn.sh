#!/bin/bash
MYIP=$(wget -qO- ipv4.icanhazip.com);
echo "Checking VPS"
clear

export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
IPVPS=$(curl -s ipinfo.io/ip)
ANU=$(ip -o $ANU -4 route show to default | awk '{print $5}');
apt install openvpn easy-rsa unzip -y
apt install openssl iptables iptables-persistent -y
mkdir -p /etc/openvpn/server/easy-rsa/
cd /etc/openvpn/
wget https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/vpn.zip
unzip vpn.zip
rm -f vpn.zip
chown -R root:root /etc/openvpn/server/easy-rsa/

cd
mkdir -p /usr/lib/openvpn/
cp /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so /usr/lib/openvpn/openvpn-plugin-auth-pam.so
sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn
systemctl enable --now openvpn-server@server-tcp
systemctl enable --now openvpn-server@server-udp
/etc/init.d/openvpn restart
/etc/init.d/openvpn status
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

cat > /etc/openvpn/client-tcp-1194.ovpn <<-END
client
dev tun
proto tcp
remote $IPVPS 1194
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
<ca>
-----BEGIN CERTIFICATE-----
MIID9DCCAtygAwIBAgIUEwUTqjTlDgQEVDRH2U80fHTgWmswDQYJKoZIhvcNAQEL
BQAwdjETMBEGA1UEAwwKQ0EgT3BlblZwbjELMAkGA1UEBhMCSUQxEDAOBgNVBAcM
B0pha2FydGExFDASBgNVBAgMC0tlYm9uIEplcnVrMQ4wDAYDVQQKDAVHSVZQTjEa
MBgGA1UECwwRSU5ET05FU0lBIENPVU5UUlkwIBcNMjMwNjI2MDQwNTQ5WhgPMjA1
MzA2MTgwNDA1NDlaMHYxEzARBgNVBAMMCkNBIE9wZW5WcG4xCzAJBgNVBAYTAklE
MRAwDgYDVQQHDAdKYWthcnRhMRQwEgYDVQQIDAtLZWJvbiBKZXJ1azEOMAwGA1UE
CgwFR0lWUE4xGjAYBgNVBAsMEUlORE9ORVNJQSBDT1VOVFJZMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4Hc5wLfc1lE9tud9nqV9tIXi39yko4SmCTy7
vnitIZ5E7jStCae5L5K8fdLutab3sQ2VG8/9qypc5uKVV7mVBMsfooAz6Jco0jkY
8Wl9BiBizNy0a78tCtl3OkIoSSoYb5TOwHRcRRXGDSiWAJ6EpJWUmD/BQIPbJH93
ufO4raIhiBtG0OyirW0OcW7n2Q4VOV7iaZzSJeydUW7PT1biQ4ZGqDJEaHLudLrA
Z0A8Fdg9hFlv9dWt/FSQa5hmZd+ogJWDDsxsqc7EU7EVqW4Q4rXUXHJ6r4ETnKgf
2/jzl2iLQ94JHWR5V5wO2d3osEix5auoVAotCnBTH9AF/OjFfwIDAQABo3gwdjAd
BgNVHQ4EFgQUrOHnpk8NhFrZ9uq56XyahxNjrmcwHwYDVR0jBBgwFoAUrOHnpk8N
hFrZ9uq56XyahxNjrmcwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUEDDAKBggrBgEF
BQcDATAOBgNVHQ8BAf8EBAMCAaYwDQYJKoZIhvcNAQELBQADggEBALzgpdiWweYN
3FgiVjIuEZiSyMnTkcJlgoCwaBrDNUFz/ZSbKin+u8rNMn6U7Wpu9kEhqgft5F7W
E//mXzfBMTjuSwirp6sjEaZjybSAw5vCER7dq3GE2MOF53lu56lHeg6p2TMV2Ep5
QQv2v4kwJV10q3h1kGTFawNy7cC0gBAfQADk5TkPqxUPsrHWd8CHqX3qj9Z4aSpV
39FVQltJtF6aE35rczVU5ETnAjI6fGG/+bXmrhwfWk926/J+VZcqZqWS3ZgT3p5x
vO6dNnG6EAoe0TSQV54QDMN1Eung42Oxa1QnOqVBSlhtvITYB8EubmrcwIovtME6
sX4fPkXFnrg=
-----END CERTIFICATE-----
</ca>
END

cat > /var/www/html/client-tcp-1194.ovpn <<-END
client
dev tun
proto tcp
remote $IPVPS 1194
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
<ca>
-----BEGIN CERTIFICATE-----
MIID9DCCAtygAwIBAgIUEwUTqjTlDgQEVDRH2U80fHTgWmswDQYJKoZIhvcNAQEL
BQAwdjETMBEGA1UEAwwKQ0EgT3BlblZwbjELMAkGA1UEBhMCSUQxEDAOBgNVBAcM
B0pha2FydGExFDASBgNVBAgMC0tlYm9uIEplcnVrMQ4wDAYDVQQKDAVHSVZQTjEa
MBgGA1UECwwRSU5ET05FU0lBIENPVU5UUlkwIBcNMjMwNjI2MDQwNTQ5WhgPMjA1
MzA2MTgwNDA1NDlaMHYxEzARBgNVBAMMCkNBIE9wZW5WcG4xCzAJBgNVBAYTAklE
MRAwDgYDVQQHDAdKYWthcnRhMRQwEgYDVQQIDAtLZWJvbiBKZXJ1azEOMAwGA1UE
CgwFR0lWUE4xGjAYBgNVBAsMEUlORE9ORVNJQSBDT1VOVFJZMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4Hc5wLfc1lE9tud9nqV9tIXi39yko4SmCTy7
vnitIZ5E7jStCae5L5K8fdLutab3sQ2VG8/9qypc5uKVV7mVBMsfooAz6Jco0jkY
8Wl9BiBizNy0a78tCtl3OkIoSSoYb5TOwHRcRRXGDSiWAJ6EpJWUmD/BQIPbJH93
ufO4raIhiBtG0OyirW0OcW7n2Q4VOV7iaZzSJeydUW7PT1biQ4ZGqDJEaHLudLrA
Z0A8Fdg9hFlv9dWt/FSQa5hmZd+ogJWDDsxsqc7EU7EVqW4Q4rXUXHJ6r4ETnKgf
2/jzl2iLQ94JHWR5V5wO2d3osEix5auoVAotCnBTH9AF/OjFfwIDAQABo3gwdjAd
BgNVHQ4EFgQUrOHnpk8NhFrZ9uq56XyahxNjrmcwHwYDVR0jBBgwFoAUrOHnpk8N
hFrZ9uq56XyahxNjrmcwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUEDDAKBggrBgEF
BQcDATAOBgNVHQ8BAf8EBAMCAaYwDQYJKoZIhvcNAQELBQADggEBALzgpdiWweYN
3FgiVjIuEZiSyMnTkcJlgoCwaBrDNUFz/ZSbKin+u8rNMn6U7Wpu9kEhqgft5F7W
E//mXzfBMTjuSwirp6sjEaZjybSAw5vCER7dq3GE2MOF53lu56lHeg6p2TMV2Ep5
QQv2v4kwJV10q3h1kGTFawNy7cC0gBAfQADk5TkPqxUPsrHWd8CHqX3qj9Z4aSpV
39FVQltJtF6aE35rczVU5ETnAjI6fGG/+bXmrhwfWk926/J+VZcqZqWS3ZgT3p5x
vO6dNnG6EAoe0TSQV54QDMN1Eung42Oxa1QnOqVBSlhtvITYB8EubmrcwIovtME6
sX4fPkXFnrg=
-----END CERTIFICATE-----
</ca>
END

cat > /etc/openvpn/client-udp-2200.ovpn <<-END
client
dev tun
proto udp
remote $IPVPS 2200
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
<ca>
-----BEGIN CERTIFICATE-----
MIID9DCCAtygAwIBAgIUEwUTqjTlDgQEVDRH2U80fHTgWmswDQYJKoZIhvcNAQEL
BQAwdjETMBEGA1UEAwwKQ0EgT3BlblZwbjELMAkGA1UEBhMCSUQxEDAOBgNVBAcM
B0pha2FydGExFDASBgNVBAgMC0tlYm9uIEplcnVrMQ4wDAYDVQQKDAVHSVZQTjEa
MBgGA1UECwwRSU5ET05FU0lBIENPVU5UUlkwIBcNMjMwNjI2MDQwNTQ5WhgPMjA1
MzA2MTgwNDA1NDlaMHYxEzARBgNVBAMMCkNBIE9wZW5WcG4xCzAJBgNVBAYTAklE
MRAwDgYDVQQHDAdKYWthcnRhMRQwEgYDVQQIDAtLZWJvbiBKZXJ1azEOMAwGA1UE
CgwFR0lWUE4xGjAYBgNVBAsMEUlORE9ORVNJQSBDT1VOVFJZMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4Hc5wLfc1lE9tud9nqV9tIXi39yko4SmCTy7
vnitIZ5E7jStCae5L5K8fdLutab3sQ2VG8/9qypc5uKVV7mVBMsfooAz6Jco0jkY
8Wl9BiBizNy0a78tCtl3OkIoSSoYb5TOwHRcRRXGDSiWAJ6EpJWUmD/BQIPbJH93
ufO4raIhiBtG0OyirW0OcW7n2Q4VOV7iaZzSJeydUW7PT1biQ4ZGqDJEaHLudLrA
Z0A8Fdg9hFlv9dWt/FSQa5hmZd+ogJWDDsxsqc7EU7EVqW4Q4rXUXHJ6r4ETnKgf
2/jzl2iLQ94JHWR5V5wO2d3osEix5auoVAotCnBTH9AF/OjFfwIDAQABo3gwdjAd
BgNVHQ4EFgQUrOHnpk8NhFrZ9uq56XyahxNjrmcwHwYDVR0jBBgwFoAUrOHnpk8N
hFrZ9uq56XyahxNjrmcwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUEDDAKBggrBgEF
BQcDATAOBgNVHQ8BAf8EBAMCAaYwDQYJKoZIhvcNAQELBQADggEBALzgpdiWweYN
3FgiVjIuEZiSyMnTkcJlgoCwaBrDNUFz/ZSbKin+u8rNMn6U7Wpu9kEhqgft5F7W
E//mXzfBMTjuSwirp6sjEaZjybSAw5vCER7dq3GE2MOF53lu56lHeg6p2TMV2Ep5
QQv2v4kwJV10q3h1kGTFawNy7cC0gBAfQADk5TkPqxUPsrHWd8CHqX3qj9Z4aSpV
39FVQltJtF6aE35rczVU5ETnAjI6fGG/+bXmrhwfWk926/J+VZcqZqWS3ZgT3p5x
vO6dNnG6EAoe0TSQV54QDMN1Eung42Oxa1QnOqVBSlhtvITYB8EubmrcwIovtME6
sX4fPkXFnrg=
-----END CERTIFICATE-----
</ca>
END

cat > /var/www/html/client-udp-2200.ovpn <<-END
client
dev tun
proto udp
remote $IPVPS 2200
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
<ca>
-----BEGIN CERTIFICATE-----
MIID9DCCAtygAwIBAgIUEwUTqjTlDgQEVDRH2U80fHTgWmswDQYJKoZIhvcNAQEL
BQAwdjETMBEGA1UEAwwKQ0EgT3BlblZwbjELMAkGA1UEBhMCSUQxEDAOBgNVBAcM
B0pha2FydGExFDASBgNVBAgMC0tlYm9uIEplcnVrMQ4wDAYDVQQKDAVHSVZQTjEa
MBgGA1UECwwRSU5ET05FU0lBIENPVU5UUlkwIBcNMjMwNjI2MDQwNTQ5WhgPMjA1
MzA2MTgwNDA1NDlaMHYxEzARBgNVBAMMCkNBIE9wZW5WcG4xCzAJBgNVBAYTAklE
MRAwDgYDVQQHDAdKYWthcnRhMRQwEgYDVQQIDAtLZWJvbiBKZXJ1azEOMAwGA1UE
CgwFR0lWUE4xGjAYBgNVBAsMEUlORE9ORVNJQSBDT1VOVFJZMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4Hc5wLfc1lE9tud9nqV9tIXi39yko4SmCTy7
vnitIZ5E7jStCae5L5K8fdLutab3sQ2VG8/9qypc5uKVV7mVBMsfooAz6Jco0jkY
8Wl9BiBizNy0a78tCtl3OkIoSSoYb5TOwHRcRRXGDSiWAJ6EpJWUmD/BQIPbJH93
ufO4raIhiBtG0OyirW0OcW7n2Q4VOV7iaZzSJeydUW7PT1biQ4ZGqDJEaHLudLrA
Z0A8Fdg9hFlv9dWt/FSQa5hmZd+ogJWDDsxsqc7EU7EVqW4Q4rXUXHJ6r4ETnKgf
2/jzl2iLQ94JHWR5V5wO2d3osEix5auoVAotCnBTH9AF/OjFfwIDAQABo3gwdjAd
BgNVHQ4EFgQUrOHnpk8NhFrZ9uq56XyahxNjrmcwHwYDVR0jBBgwFoAUrOHnpk8N
hFrZ9uq56XyahxNjrmcwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUEDDAKBggrBgEF
BQcDATAOBgNVHQ8BAf8EBAMCAaYwDQYJKoZIhvcNAQELBQADggEBALzgpdiWweYN
3FgiVjIuEZiSyMnTkcJlgoCwaBrDNUFz/ZSbKin+u8rNMn6U7Wpu9kEhqgft5F7W
E//mXzfBMTjuSwirp6sjEaZjybSAw5vCER7dq3GE2MOF53lu56lHeg6p2TMV2Ep5
QQv2v4kwJV10q3h1kGTFawNy7cC0gBAfQADk5TkPqxUPsrHWd8CHqX3qj9Z4aSpV
39FVQltJtF6aE35rczVU5ETnAjI6fGG/+bXmrhwfWk926/J+VZcqZqWS3ZgT3p5x
vO6dNnG6EAoe0TSQV54QDMN1Eung42Oxa1QnOqVBSlhtvITYB8EubmrcwIovtME6
sX4fPkXFnrg=
-----END CERTIFICATE-----
</ca>
END

iptables -t nat -I POSTROUTING -s 10.6.0.0/24 -o $ANU -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.7.0.0/24 -o $ANU -j MASQUERADE
iptables-save > /etc/iptables.up.rules
chmod +x /etc/iptables.up.rules

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -s 10.6.0.0/24 -o eth0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 10.7.0.0/24 -o eth0 -j MASQUERADE
sudo iptables-save > /etc/iptables/rules.v4

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -s 10.6.0.0/24 -o eth0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 10.7.0.0/24 -o eth0 -j MASQUERADE
sudo iptables-save > /etc/iptables/rules.v4

iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

systemctl enable openvpn
systemctl start openvpn
/etc/init.d/openvpn restart

history -c
rm -f /root/ovpn.sh
