FROM ubuntu:latest

MAINTAINER Nicolas Justiniano <n.justiniano@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq -y update && \
	apt-get -qq -y upgrade && \
    apt-get -qq -y install build-essential icecast2 mpc mpd awscli python-pip fuse sudo supervisor fapg && \
    apt-get clean

RUN mkdir -p /opt/music && \
    mkdir -p /opt/playlists && \
    mkdir -p /usr/local/audio/voiceovers && \
    chown mpd. /opt/music /opt/playlists /usr/local/audio/voiceovers

RUN chmod g+w /opt/music /opt/playlists /usr/local/audio/voiceovers

#COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#S3
RUN pip install --upgrade pip
RUN pip install yas3fs
RUN sed -i'' 's/^# *user_allow_other/user_allow_other/' /etc/fuse.conf && chmod a+r /etc/fuse.conf

VOLUME /opt/music

# ADD ./entrypoint.sh /entrypoint.sh
# RUN chmod 755 /entrypoint.sh
# ENTRYPOINT ["sh", "/entrypoint.sh"]
CMD ["/start.sh"]
EXPOSE 8000 6600
VOLUME ["/config", "/var/log/icecast2", "/etc/icecast2", "/opt/music", "/opt/playlists", "/usr/local/audio/voiceovers"]

ADD ./mpd.conf /etc/mpd.conf
ADD ./start.sh /start.sh
ADD ./voiceovers /usr/local/audio/voiceovers
ADD ./radio /opt/music
ADD ./icecast.xml /etc/icecast2/icecast.xml
ADD ./icecast2 /etc/default/icecast2
ADD ./silence.ogg /usr/share/icecast2/web/silence.ogg
RUN chown -R icecast2 /etc/icecast2

RUN echo 'mpd : ALL' >> /etc/hosts.allow
