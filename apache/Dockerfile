FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo

# Update packages and install dependencies including Apache, Lua, and LuaRocks
RUN apt-get update && \
    apt-get install -y tzdata apache2 lua5.3 lua5.3-dev luarocks build-essential wget && \
    rm -rf /var/lib/apt/lists/*

# Install CGILua and WSAPI using LuaRocks
RUN luarocks install cgilua && luarocks install wsapi

# Enable Apache CGI module
RUN a2enmod cgi

# In a production deployment, files should be copied
# COPY html/ /var/www/html/

# Set the global DirectoryIndex to include index.lp before index.html
RUN cat <<EOF > /etc/apache2/mods-enabled/dir.conf
<IfModule mod_dir.c>
    DirectoryIndex index.lp index.html
</IfModule>
EOF

# Configure Apache to execute .lp files as CGI scripts
RUN echo '<Directory /var/www/html>' > /etc/apache2/conf-available/cgilua.conf && \
    echo '    Options +ExecCGI' >> /etc/apache2/conf-available/cgilua.conf && \
    echo '    AddHandler cgi-script .lp' >> /etc/apache2/conf-available/cgilua.conf && \
    echo '</Directory>' >> /etc/apache2/conf-available/cgilua.conf && \
    a2enconf cgilua

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]