wget http://wordpress.org/latest.tar.gz
tar xfz latest.tar.gz
mv wordpress web
cp .env.example .env
docker-compose up -d
