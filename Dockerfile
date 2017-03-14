FROM resin/raspberrypi2-python:3.6

#----------------------
# add node
# https://github.com/resin-io-library/base-images/blob/master/node/raspberry-pi2/debian/default/slim/Dockerfile
ENV NODE_VERSION 0.10.22

RUN buildDeps='curl' \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& curl -SLO "http://resin-packages.s3.amazonaws.com/node/v$NODE_VERSION/node-v$NODE_VERSION-linux-armv7hf.tar.gz" \
	&& echo "d72e7f3908738ed502ebd53552619c955bbd13cf4e7e0f88cfb0ea2c5a396005  node-v0.10.22-linux-armv7hf.tar.gz" | sha256sum -c - \
	&& tar -xzf "node-v$NODE_VERSION-linux-armv7hf.tar.gz" -C /usr/local --strip-components=1 \
	&& rm "node-v$NODE_VERSION-linux-armv7hf.tar.gz" \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& npm config set unsafe-perm true -g --unsafe-perm \
	&& rm -rf /tmp/*
#----------------------

# kijani light sensor poll script deps
RUN npm install -g forever forever-monitor

# Install Python and livestreamer deps
RUN apt-get update \
  && apt-get install -y \
  openssh-server \
  # omxplayer & streamlink deps
  omxplayer \
  librtmp-dev \
  libffi-dev \
  # Remove package lists to free up space
  && rm -rf /var/lib/apt/lists/*

# here we set up the config for openSSH.
# depends on openssh-server (above)
# https://github.com/resin-io-projects/resin-openssh/blob/master/Dockerfile.template
RUN mkdir /var/run/sshd \
  && echo 'root:resin' | chpasswd \
  && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config \
  && echo ". <(xargs -0 bash -c 'printf \"export %q\n\" \"\$@\"' -- < /proc/1/environ)" >> /root/.profile \
  && echo "cd /app" >> /root/.bashrc

# copy current directory into /app
COPY . /app

WORKDIR /app/streamlink-src

# install python modules
# use `RUN pip install -r /requirements.txt` for better container caching
# RUN python -m pip install python-librtmp streamlink
RUN python -m pip install python-librtmp

# use beardypig/streamlink:ustream-websockets branch b/c ustream plugin not
# fixed in main streamlink repo yet (Mar 2017)
# https://github.com/beardypig/streamlink/tree/ustream-websockets
RUN python setup.py install

WORKDIR /app

# TODO notsure
# Enable systemd
ENV INITSYSTEM on

# exec our app. Note: iss-streamer uses infinite loop catch/restart
CMD ["/bin/bash", "/app/start.sh"]
