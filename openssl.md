# CA与自签名
## 制作CA私钥
`openssl genrsa -out ca.key 2048`

## 制作CA公钥/根证书
`openssl req -new -x509 -days 3650 -key ca.key -out ca.crt`
- Common Name 随意填写；其它填写”.”



# 服务器端证书
## 制作服务器私钥
`openssl genrsa -out server.pem 1024`
`openssl rsa -in server.pem -out server.key`

## 生成签发请求
`openssl req -new -key server.pem -out server.csr`
- Common Name填写访问服务器时域名，配置nginx时用到，不能与CA的相同其它填写”.”

## 用CA签发证书
`openssl x509 -req -sha256 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 3650 -out server.crt`

服务器端的证书和客户端的证书签发证书的过程其实是完全一样的，只是这里的命名上稍微做了一点点区别


#客户端证书
## 制作私钥
`openssl genrsa -out client.pem 1024`
`openssl rsa -in client.pem -out client.key`

## 生成签发请求
`openssl req -new -key client.pem -out client.csr`
- Common Name填写访问服务器时域名，配置nginx时用到，不能与CA的相同 其它填写”.”

## 用CA签发
`openssl x509 -req -sha256 -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 3650 -out client.crt`

## 使用浏览器访问时，需要生成p12格式的客户端证书
`openssl pkcs12 -export -clcerts -in client.crt -inkey client.key -out client.p12`


# 配置NGINX
## 配置https双向认证的主要配置
```
listen 443 ssl;
server_name hostName;
server_tokens off;
ssl on;
ssl_certificate      server.crt;  # server证书公钥
ssl_certificate_key  server.key;  # server私钥
ssl_client_certificate ca.crt;  # 根级证书公钥，用于验证各个二级client
ssl_verify_client on;  # 开启客户端证书验证

# 配置好后重新加载nginx
service nginx reload
```

## 测试 命令行Curl测试
`curl --insecure --key client.key --cert client.crt hostName`
- 收到网页信息，成功

## 浏览器访问测试
- 把client.p12导入到浏览器的https配置中，访问站点建立连接的时候nginx会要求客户端把这个证书发给自己验证，如果没有这个证书就拒绝访问。

# 如何获取证书中的用户邮箱信息
```
nginx ssl模块有个变量：$ssl_client_s_dn，这个变量存储的是认证信息，内容格式如下： emailAddress=client email,CN=server host name,通过在nginx中使用该变量配置个请求头，可以在 业务代码中获取这个信息，然后从其中解析出邮箱信息。
参考链接

https://segmentfault.com/a/1190000002866627%
```
