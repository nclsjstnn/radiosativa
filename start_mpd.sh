#!/bin/sh

######################################################################
#                                                                    #
#  This script is designed to be run as a cronjob and to cause a     #
#  voiceover to be played after fading out some background music.    #
#  It is primarily designed for use when MPD is being used as a      #
#  hold music system and you wish to have voice overs to advertise   #
#  products or services.                                             #
#                                                                    #
#  I'm sure this could be done more efficiently and cleanly, but     #
#  it's only designed to run on an internal server with low load so  #
#  this is not an issue for me.                                      #
#                                                                    #
#  $PLAYLIST defines the default m3u format playlist to be used for  #
#            selecting the background/hold music.                    #
#  $VOICEOVER_DIRECTORY is a directory containing the MP3 voiceover  #
#            samples.                                                #
#  $NORMAL_VOLUME is the volume at which MPD normally outputs its    #
#            audio.                                                  #
#  $FADED_VOLUME is the volume at which MPD will play the music      #
#            during the voiceover.                                   #
#  $FADE_TIME is the time taken for the current song to fade in or   #
#            out.                                                    #
#  $CROSSFADE_TIME is the time it takes from one song to fade to     #
#            the next.                                               #
#                                                                    #
#  $MPC is the command for the MPD client.                           #
#  $BC is the calculator                                             #
#  $MPD_CONTROLLER is the script used to start/stop/restart MPD      #
#  $MPD_RUN_FILE is the PID file for MPD                             #
#                                                                    #
#                                                                    #
#  Author: Michael Lambert <michael.lambert[at]crankyotter[dot]com   #
#  Webpage: http://www.crankyotter.com                               #
#  Licence: GNU General Public Licence                               #
#  Date: 20th January 2011                                           #
#  Reason: I struggled to find anything to allow me to implement a   #
#          voiceover for my telephone hold music through a           #
#          traditional phone system.  Modifying Hack:mpc-fade has    #
#          provided me with a solution that works and removes many   #
#          of the restrictions hardware solutions enforce.           #
#                                                                    #
#  Credits: This script would not have been possible without         #
#           Hack:mpc-fade by Maxime Petazzonio aka Sam as            #
#           available at http://mpd.wikia.com/wiki/Hack:mpc-fade     #
#                                                                    #
######################################################################

###
# Define some variables that are user configurable

PLAYLIST="/opt/playlists/sativo.m3u"
VOICEOVER_DIRECTORY="/usr/local/audio/voiceovers/"
NORMAL_VOLUME=100
FADED_VOLUME=30
FADE_TIME=3
CROSSFADE_TIME=5

#
###

###
# Define some variable that are system specific

MPC=`which mpc`
BC="`which bc` -l"
MPD_CONTROLLER="/etc/init.d/mpd"
MPD_RUN_FILE="/run/mpd/pid"

#
###

###
# Check if MPD is running

if [ ! -e $MPD_RUN_FILE ]
then
    ###
    # MPD isn't running, restart it
    $MPD_CONTROLLER restart > dev/null
    mpc update > dev/null
    mpc random on > dev/null
    mpc repeat on > dev/null
    mpc volume $NORMAL_VOLUME > /dev/null
    mpc crossfade $CROSSFADE_TIME > /dev/null
    mpc play > dev/null
    #
    ###
fi

#
###

###
# Check if MPD is actually playing some songs

if [ `mpc playlist | wc -l` -eq 0 ]
then
    ###
    # MPD isn't playing, restart it and queue the songs
    $MPD_CONTROLLER restart > dev/null
    mpc update > dev/null
    mpc clear > dev/null
    cat $PLAYLIST | mpc add > dev/null
    mpc random on > dev/null
    mpc repeat on > dev/null
    mpc volume $NORMAL_VOLUME > /dev/null
    mpc crossfade $CROSSFADE_TIME > /dev/null
    mpc play > dev/null
    #
    ###
fi

#
###

###
# Reset the volume just in case it's been manually adjusted

mpc volume $NORMAL_VOLUME > dev/null

#
###

###
# Fade the current song out

VOLUME = $(($NORMAL_VOLUME - 1))
while [ $VOLUME -ge $FADED_VOLUME ]
do
    mpc volume $VOLUME > /dev/null
    VOLUME = $(($VOLUME - 1))
    sleep `echo "$FADE_TIME/($NORMAL_VOLUME - $FADED_VOLUME)" | $BC`
done

#
###

###
# Select a random voiceover

VOICEOVER_FILENAME=`/bin/ls -1 "$VOICEOVER_DIRECTORY" | grep "mp3" | sort --random-sort | head -1`
VOICEOVER_FILE=`readlink --canonicalize "$VOICEOVER_DIRECTORY/$VOICEOVER_FILENAME"`

#
###

###
# Play the voiceover

mpg123 $VOICEOVER_FILE > /dev/null

#
###

###
# Fade the current song in

while [ $VOLUME -le $NORMAL_VOLUME ]
do
    mpc volume $VOLUME > /dev/null
    VOLUME = $(($VOLUME + 1))
    sleep `echo "$FADE_TIME/($NORMAL_VOLUME - $FADED_VOLUME)" | $BC`
done

#
###

exit 0