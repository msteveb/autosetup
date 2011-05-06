test: auto.def ../autosetup
	@ENV1=abc ENVCLI=def ENV0= ./configure CLI1=ghi ENVCLI=jkl CLI0=

# Test an out-of-tree configure
subdirtest: auto.def ../autosetup
	@mkdir -p _build
	@cd _build; ENV1=abc ENVCLI=def ENV0= ../configure CLI1=ghi ENVCLI=jkl CLI0= OOT=1
	@rmdir _build
