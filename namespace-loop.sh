#!/bin/bash
secret_name="my-secret"
p12Encode=$(echo -n admin | base64)
pwdEncode=$(echo -n password | base64)
echo "p12Encode is $p12Encode"
echo "pwdEncode is $pwdEncode"
echo "Now will checking namespace"

awk 'BEGIN{while (a++<50) s=s "-"; print s,"splite line",s}'
kubectl get ns | grep -E "lextest|alex" | awk '{print$1}' | while IFS='' read -r line; do
	echo "starting=======›create secret in namespace: ""$line"" "
	kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: $secret_name
  namespace: ${line}
type: Opaque
data:
  test-pw.p12: $p12Encode
  test-pw.p12.pwd: $pwdEncode
EOF

	kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: ${line}
  name: test-common-sb-conf
data:
  server-conf.properties: 
    server.port=443
    server.ssl.enabled=true
    server.ssl.key-store=/opt/keystore/test-pw.p12
    server.ssl.key-store-type=PKCS12
    server.ssl.key-store-password=\${KEY_STORE_PWD}
    server.servlet.context-path=/\$(apiName}/v\${minorVersion}
EOF

done
