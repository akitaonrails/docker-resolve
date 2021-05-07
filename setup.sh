#!/bin/bash
_archive=DaVinci_Resolve_Studio_17.1.1_Linux
unzip $_archive.zip
./$_archive.run --appimage-extract
tar cvfz davinci-studio.tgz squashfs-root/
rm -rf squashfs-root
rm -rf $_archive.run
rm -rf $_archive.zip
rm -rf *.pdf
docker build . -t davinci-studio
