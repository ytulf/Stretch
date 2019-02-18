firefox https://get.adobe.com/fr/flashplayer/download/?installer=FP_28.0_for_Linux_64-bit_(.tar.gz)_-_NPAPI&stype=7784&standalone=1
tar -xzf ~/Download/flash_player_npapi_linux.x86_64.tar.gz
cp libflashplayer.so /usr/lib/mozzila/plugins/
cp -r usr/* /usr