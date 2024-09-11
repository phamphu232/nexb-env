
# nexb-ENV

## 1. Preparing

```
# Install docker
https://docs.docker.com/engine/install/ubuntu/

# Add current user to docker group
sudo usermod -aG docker $(whoami)
logout

# Update .env file
cp .env.example .env

## Create network
docker network create -d bridge --subnet=10.10.10.0/24 nexb_net
```

## 2. Create proxy server

```
cp docker-compose.yml.example docker-compose.yml
docker compose up -d --build

## Config a proxy site
### Check example file: nginx/conf.d/hello-world.local.conf
```

## 3. Build web server image

```
chmod +x ./build.sh
./build.sh
```

## 4. Clone a web server

### Create `nexb1` server

```
cp -r servers/template servers/nexb1
```

### Change the `ipv4_address` in the `servers/nexb1/docker-compose.yml` file.

```
nano servers/nexb1/docker-compose.yml

# Example:
## nexb1: 10.10.10.10 -> 10.10.10.11
## nexb2: 10.10.10.10 -> 10.10.10.12
...
## nexb254: 10.10.10.10 -> 10.10.10.254
```

### Create/Start/Stop/Restart/Remove `nexb1` container

```
cd servers/nexb1

# Create and start
docker compose up -d --build

# Start
docker compose start

# Stop
docker compose stop

# Restart
docker compose restart

# Remove
docker compose down
```

### Add a site to `nexb1` server

```
 ## Check example file: servers/nexb1/apache2/sites-enabled/hello-world.local.conf
```

## 5. Config logrotate

### Logrotate nginx proxy

```
# Create file: /etc/logrotate.d/nginx
/home/ubuntu/nexb-env/log/nginx/*.log {
    dateext
    daily
    rotate 31
    nocreate
    missingok
    notifempty
    nocompress
    postrotate
        /usr/bin/docker exec nexb-proxy /bin/sh -c '/usr/sbin/nginx -s reopen > /dev/null'
    endscript
}
```

### Logrotate web server

```
# Create file: /etc/logrotate.d/nexb1
/home/ubuntu/nexb-env/servers/nexb1/log/apache2/*.log {
    dateext
    daily
    rotate 31
    nocreate
    missingok
    notifempty
    nocompress
    postrotate
        /usr/bin/docker exec nexb1-server-1 /bin/sh -c '/etc/init.d/apache2 reload > /dev/null'
    endscript
}
# Note: change the 'nexb1-server-1' for other web server container
```

- Logrotate uses crontab to work. It's scheduled work, not a daemon, so no need to reload its configuration.
- When the crontab executes logrotate, it will use your new config file automatically.
- If you need to test your config you can also execute logrotate on your own with the command:

```
## Syntax:
# logrotate /etc/logrotate.d/your-logrotate-config

## Example:
logrotate /etc/logrotate.d/nginx
```

- If you want to have a debug output use argument -d

```
## Syntax:
# logrotate -v /etc/logrotate.d/your-logrotate-config

## Example:
logrotate -v /etc/logrotate.d/nginx
```

## User full command

```
# The resource usage statistics of docker
docker stats
docker system df

# List all containers
docker ps -a

# Check logs container.
docker logs <container_id>
docker logs <container_name>

# Access into a running container.
docker exec -it <container_id> sh
docker exec -it <container_name> sh

# Executing a command inside a container.
docker exec <container_name> sh -c "your_command_or_path_to_a_script"
docker exec <container_name> bash -c "your_command_or_path_to_a_script"

# Prune docker resources unused
docker image prune
docker volume prune
docker builder prune

## Create ssl self certificates
openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -keyout self-signed.key -out self-signed.crt
```
