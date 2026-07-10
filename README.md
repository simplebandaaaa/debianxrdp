docker build -t ubuntu-desktop-rdp .
docker run -d -p 3389:3389 --name my-desktop ubuntu-desktop-rdp
