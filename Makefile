all:
	echo "nothing to do. run make install"

install:
	mkdir -p /usr/share/bpjm
	cp fb_bpjm_downloader.sh /usr/bin/fb_bpjm_downloader
	crontab -l | { cat; echo "0 */6 * * * /usr/bin/fb_bpjm_downloader"; } | crontab -

remove:
	rm -r /usr/share/bpjm
	rm -f /usr/bin/fb_bpjm_downloader
	crontab -l | grep -v fb_bpjm_downloader | crontab -
