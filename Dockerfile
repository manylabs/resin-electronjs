FROM resin/raspberrypi2-python:3.6

# Install Python and flite deps.
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
