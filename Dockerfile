FROM debian:bullseye

ENV HOME=/root
WORKDIR $HOME

COPY waitonprocess.sh /scripts/
RUN chmod +x /scripts/waitonprocess.sh

# Base
RUN true \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
		apt-utils \
		procps \
        ca-certificates \
		ssh \
        make \
		git \
        wget \
		curl \
		p7zip-full \
    && rm -rf /var/lib/apt/lists/*

ENV WINEARCH=win64 \
    WINEPREFIX=$HOME/.wine64 \
	WINEDEBUG=-all

# Wine
RUN true \
	&& apt-get -qq update \
	&& apt-get -qq install -y --no-install-recommends\
		gnupg2 \
		software-properties-common \
	&& wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
	&& add-apt-repository 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main' \
	&& rm -rf /var/lib/apt/lists/* 
	
RUN true \
	&& dpkg --add-architecture i386 \
	&& apt-get -qq update \
	&& apt-get -qq install -y --no-install-recommends \
		# winehq-stable \
		winehq-devel \
		xvfb \
		xauth \
	&& wine --version \
	&& /scripts/waitonprocess.sh wineserver \
	&& rm -rf /var/lib/apt/lists/* 
	
# Winetricks
RUN true \
	&& wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
	&& chmod +x winetricks \
	&& mv winetricks /usr/local/bin \
	# && winetricks -q win10 \
	&& winetricks -q vista \
	&& /scripts/waitonprocess.sh wineserver

RUN true \
    && wine hostname > /dev/null \
    && /scripts/waitonprocess.sh wineserver
	
COPY addpath.sh /scripts/
RUN chmod +x /scripts/addpath.sh

RUN true \
	&& mkdir downloads/
    	
# Git for Windows	
RUN true \
	&& wget -q https://github.com/git-for-windows/git/releases/download/v2.33.1.windows.1/Git-2.33.1-64-bit.exe -O downloads/git-setup.exe \
	&& xvfb-run wine \
		downloads/git-setup.exe /SP- /VERYSILENT /SUPPRESSMSGBOXES /DIR="C:\\git" \
	&& rm -rf downloads/git-setup.exe \
 	&& /scripts/addpath.sh $(winepath -w "$WINEPREFIX/drive_c/git/bin") \
 	&& /scripts/addpath.sh $(winepath -w "$WINEPREFIX/drive_c/git/usr/bin") \
 	&& /scripts/waitonprocess.sh wineserver
	
COPY git_for_windows/msys-2.0.dll downloads/msys-2.0.dll
RUN true \
	&& mv downloads/msys-2.0.dll "$WINEPREFIX/drive_c/git/usr/bin" 

RUN true \
	&& wget -q https://github.com/PowerShell/Win32-OpenSSH/releases/download/V8.6.0.0p1-Beta/OpenSSH-Win64.zip -O downloads/openssh.zip \
	&& 7z x downloads/openssh.zip -o"$WINEPREFIX/drive_c/" \
	&& rm -rf downloads/openssh.zip \
	&& /scripts/addpath.sh $(winepath -w "$WINEPREFIX/drive_c/OpenSSH-Win64") \
	&& /scripts/waitonprocess.sh wineserver

# SHELL ["/bin/bash", "-c"]

RUN true \
	&& GIT_TRACE=true wine git config --system --add core.sshCommand "C:/OpenSSH-Win64/ssh.exe" \
	&& /scripts/waitonprocess.sh wineserver

RUN true \
	&& rm -rf downloads/
	