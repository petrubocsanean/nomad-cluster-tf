# Cloudflare full-strict SSL

1. Go to SSL/TLS Origin Server and Create a Certificate
2. Copy the contents of private key and private certificate
3. Edit traefik-full-strict.hcl job and replace <INSERT HERE> with the private key and certificate
4. Run traefik-full-strict.hcl nomad job

