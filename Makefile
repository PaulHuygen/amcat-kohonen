current_dir = $(shell pwd)
workdir=$(current_dir)/nuweb
targetmake=$(workdir)/Makefile
source=a_youp_lsa_kohonen.w
bibf=lda-kohonen.bib


default: $(targetmake)

$(targetmake) : $(workdir)/$(source) $(workdir)/$(bibf)
	tar -czhf - nuweb | curl --form "stdin=@-" http://ic.vupr.nl:9081/nuweb | tar -xzf -
	ln -sf $(current_dir)/$(source) $(workdir)/$(source)
	ln -sf $(current_dir)/$(bibf) $(workdir)/$(bibf)


$(workdir)/%.bib : %.bib $(workdir)
	ln -s $(current_dir)/$< $(workdir)/$<

$(workdir)/%.w : %.w $(workdir)
	ln -s $(current_dir)/$< $(workdir)/$<

$(workdir) :
	mkdir $(workdir)
	cp amcatr.r  $(workdir)
	cp amcat_getdata.r  $(workdir)
