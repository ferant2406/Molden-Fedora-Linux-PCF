#
#	You have to toy with the value of COLOR_OFFSET 
#	(0.0 <= COLOR_OFFSET <= 1.0) it reflects the darkness
#	of the shaded plots, this can vary over X-servers
#       (You can always override it with the command line flag -c0.25)
#
#       The queue names for the submit job part can be compiled in
#       by using -DDOQUEUE
#       You have to edit xwin.c to customise the queunames and times.
#
#	You can add the mpfit module by typing 'make molden.mpfit'
#
#	Disregard compiler warnings on rdmolf.f
#
#
CC = cc
LIBS =  -lX11 -lm
LDR = ${FC} 
LIBSG = -L/usr/X11R6/lib -lGLU -lGL -lXmu -lX11 -lm
ARCH := $(shell getconf LONG_BIT)
AFLAG= -m$(ARCH)
EXTEN=
EXTENZ=
EXTRAZ= 

empty :=
choosefc := 
EXT :=
uname := $(shell uname -s)
os :=

ifeq ($(uname), Linux)
 os := $(shell head -n 1 /etc/issue | cut -d" " -f1)
 ifeq ($(os), Ubuntu)
    EXTEN = exten
    EXTENZ = exten2
    LIBSG = -L/usr/X11R6/lib -lGLU -lGL -lX11 -lm
 endif
 ifeq ($(os), Debian)
    LIBSG = -L/usr/lib/X11 -lGLU -lGL -lX11 -lm
 endif

 choosefc := 'yes'
endif

ifneq (,$(findstring CYGWIN,$(uname)))
 uname := Linux
 choosefc := 'yes'
endif

ifeq ($(uname), Darwin)
 choosefc := 'yes'
endif


ifneq ($(choosefc), $(empty))
 comg77 := $(shell which g77 | grep -i g77)
 comgfort := $(shell which gfortran | grep -i gfortran)
 ifneq ($(comg77), $(empty))
    FC = g77
 endif
 ifneq ($(comgfort), $(empty))
    FC = gfortran
 endif
endif

print-%  : ; @echo $* = $($*)
#
# Linux version
#
# Make sure the Xwindow include files are installed in an rpm package
# called libX11-devel-*
# For gmolden you also need the OpenGL include files contained in the
# rpm packages mesa-libGL-devel* and mesa-libGLU-devel-*
#
# For optimisation you can try adding the following options to
# CFLAGS & FFLAGS (Bjoern Pedersen):
#
# -O2 -malign-double -fomit-frame-pointer -funroll-loops
#
# On 64-bit Alpha-Linux add -mieee to the FFLAGS
#
# when using ggc3 instead of gcc2 add to CFLAGS: -traditional-cpp
#
# when using gfortran, replace g77 with gfortran and with some versions of the
# gfortran compiler, comment out the line
# 'external iargc' in molden.f
# with GCC4.0 or higher replace the line with:
# 'external gfortran_iargc'
#

ifeq ($(uname), Linux)
CC = gcc
comgcc := $(shell gcc --version | grep 5\.4)
ifeq ($(comgcc), $(empty))
   comgcc := $(shell gcc --version | grep 6\.)
endif
ifeq ($(comgcc), $(empty))
   comgcc := $(shell gcc --version | grep 7\.)
endif
ifeq ($(comgcc), $(empty))
   comgcc := $(shell gcc --version | grep 9\.)
#   EXTRAZ = -Wno-format-truncation
   EXTRAZ = -Wno-format-truncation
endif
ifneq ($(comgcc), $(empty))
   EXTRAZ = -Wno-implicit-function-declaration
   EXT = ${EXTRAZ}
endif
#FFLAGS = -g ${AFLAG}
FFLAGS += -g ${AFLAG} -w -fallow-argument-mismatch
LIBS =  -L/usr/X11R6/lib -lX11 -lm
ifeq ($(AFLAG),"-m64")
LIBS =  -L/usr/X11R6/lib64 -lX11 -lm
endif
LDR = ${FC} -g ${AFLAG}
CFLAGS = ${AFLAG} ${EXTRAZ} -c -g -I/usr/X11R6/include -DDOBACK -DHASTIMER -DCOLOR_OFFSET=0.0
 ifeq ($(os), Debian)
    CFLAGS = ${AFLAG} ${EXTRAZ} -c -I/usr/include/X11 -DDOBACK -DHASTIMER -DCOLOR_OFFSET=0.0
    LIBS =  -L/usr/lib/X11 -lX11 -lm
    ifeq ($(AFLAG),"-m64")
       LIBS =  -L/usr/X11R6/lib64 -lX11 -lm
    endif
 endif
ifeq ($(os), FreeBSD)
CFLAGS = ${CFLAGS} -DFREEBSD
endif
endif

ifeq ($(uname), Darwin)
#
# Mac OS X g77
#
CC=cc
FFLAGS+=-O3 -funroll-loops -DDARWIN ${EXTRAZ} -w -fallow-argument-mismatch
LIBS = -L/usr/X11R6/lib -lX11 -lm
LIBSG = -L/usr/X11R6/lib -lGLU "-Wl,-dylib_file,/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib:/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib" -lGL -lXmu -lX11 -lm
EXT= -std=gnu89 -Wno-return-type -DDARWIN ${EXTRAZ}
CFLAGS= -g -std=gnu90 -Wno-return-type -DDARWIN -I/usr/X11R6/include -DDOBACK -DHASTIMER -DCOLOR_OFFSET=0.0 -Wno-logical-op-parentheses -Wno-tautological-pointer-compare -Wno-tautological-constant-out-of-range-compare
LDR = ${FC}
endif

# Silicon Graphics
#CFLAGS = -c -DDOBACK -DHASTIMER -DCOLOR_OFFSET=0.0
#FFLAGS =   
#LDR = f77 

# Ultrix, Dec Alpha ( and best start for Unix other than below )
#
# on linux you some times need to add -Nx400 option to FFLAGS
#
#CFLAGS = -c -DDOBACK -DHASTIMER 
#FFLAGS = 
#LDR = f77

#
# Mac OS X Absoft Pro Fortran 8.0
#
#CC=cc -O2 -DHASTIMER -DDOBACK -DDARWIN -I/usr/X11R6/include
#FC=f77
#FFLAGS= -B18 -O3 -f -N15 -s
#LIBS = -L/usr/X11R6/lib -lX11 -lm -lf90math -lfio -lf77math -lU77
#LDR= ${FC}

#
# Mac OS X IBM XLF 8.1
#
#CC=cc -O2 -DHASTIMER -DDOBACK -DDARWIN -I/usr/X11R6/include
#FC=xlf
#FFLAGS= -O3 -qtune=auto -qarch=auto -qextname
#LIBS = -L/usr/X11R6/lib -lX11 -lm
#LDR= ${FC}

#
# an 64-bit Alpha-Linux system with the Compaq Fortran and C/C++ compilers
#
#CC = ccc
#CFLAGS = -std0 -c -I/usr/X11R6/include -DDOBACK -DHASTIMER -DCOLOR_OFFSET=0.0
#FC = fort
#FFLAGS =
#LIBS =  -L/usr/X11R6/lib -lX11 -lmcheck
#LDR = ${FC}
#

# AIX
#
#CFLAGS = -c -D DOBACK -D UNDERSC -D HASTIMER
#FFLAGS = 
#LDR = f77

# SUN		(on the Sun: use "limit datasize 20M" if not enough memory)
#CFLAGS = -c -DDOBACK -DHASTIMER
##CFLAGS = -c -DDOBACK -DHASTIMER -I/usr/openwin/include
#FFLAGS = -Nl90
#LDR = f77

# SUN		SOLARIS
#LIBS =  -L/usr/openwin/lib -lX11 -lm
#CFLAGS = -c -DDOBACK -DHASTIMER -I/usr/openwin/include
#FFLAGS = -Nl90
#LDR = f77

# Cray
# To Prevent the cray compiler to do stupid things, added -O0
#CFLAGS = -D DOBACK -D CRAY
#FFLAGS = -O0 -Wf"-dp"
# If you are using F90 (fortran 90) use:
#FFLAGS = -O0 -d p -e 0
#LDR = segldr

# HP-UX
# Try any of the follwing two:
#
#LIBS =  -lU77 -lX11 -lm
#CFLAGS = -c -O -D DOBACK -D HASTIMER -D UNDERSC
#FC = fort77
#FFLAGS = -O +U77
#LDR = ${FC}
####
#LIBS =  -lU77 -lX11 -lm
#CFLAGS = -Ae -c +DAportable -D DOBACK -D HASTIMER -D UNDERSC
#FC = f77
#FFLAGS = -O +U77 +DAportable
#LDR = ${FC} +DAportable

# Convex SPP-100
#
#LIBS =  -lU77 -L/usr/lib/X11R5 -lX11 -lm
#CFLAGS = -c -O -DDOBACK -DUNDERSC -I/usr/include/X11R5
#FC = fort77
#FFLAGS = -O +U77
#LDR = fort77
OBJDIR=src

OBJS = $(addprefix $(OBJDIR)/, atomdens.o molden.o above.o actcal.o basprt.o calc.o \
	caldis.o calfa.o cntour.o cnvgam.o cnvgau.o convzmat.o cross.o \
	crprod.o datin.o defpc.o defrad.o del.o denmak.o densmat.o \
	distot.o dmat.o docent.o draw.o \
	euler.o eulerh.o files.o fndcal.o gampoi.o gaupoi.o gaussian.o \
	geogam.o geogau.o getmul.o getpoi.o getreal.o gmmcnv.o grdcal.o \
	gstr.o hidedr.o impsc.o locatc.o maxmin.o mdout.o mmcnv.o \
	mopaco.o mopin.o mulprt.o occin.o oriin.o parang.o pareul.o \
	parfc.o parori.o parpla.o parstp.o planky.o plend.o plini.o \
	plmol.o plotgh.o plotgr.o plotin.o plpost.o prev.o proato.o \
	procnv.o progeo.o rdbas.o rdcor.o rdgam.o rdgaus.o rdinfo.o \
	rdpdb.o rdvect.o reada.o readel.o readvv.o renorm.o rmomen.o \
	rota.o rotatg.o rotb.o rotc.o rotcor.o rotd.o rotfir.o rotm.o \
	rotmom.o scback.o search.o searchd.o setang.o setbas.o \
	settc.o shsort.o site.o slater.o stoc.o tessa.o tk4014.o \
	tocap.o tocapf.o tomold.o under.o vaxdum.o vclr.o vec.o vlen.o \
	vsc1.o wrinfo.o zread.o samino.o prtcal.o actss.o actami.o \
	plden.o heaps.o den3d.o dencnt.o plhead.o pltab.o eucmol.o pl3dm.o \
	plbox.o selsol.o atmd.o dolift.o spaced.o snypnt.o eulstr.o \
	calct.o coeffs.o epint.o espot.o fcij.o fmt.o genaos.o rys.o \
	ryspol.o rysrot.o thrcen.o twocen.o ifblen.o rott.o plmolp.o \
	wrzmat.o rdchx.o obin.o pred.o gargpl.o inferr.o freqs.o getmop.o \
	brklin.o getzm.o xyzcoo.o geomop.o dumzm.o getxyz.o espchrg.o \
	proxim.o rdgamu.o plvrml.o molsint.o runjob.o rdmsf.o wrmsf.o \
	rdmolf.o adf_fun.o rotpol.o extbas.o rdcpmd.o eem.o asspmf.o srfcal.o \
	rdqchm.o rdorca.o rdmaux.o rdnwch.o )

DOBJ =	dummys.o dummyc.o

#
# For The OpenGL Graphics library molden helper 'moldenogl'
# (make moldenogl)
# and the full opengl version of molden 'gmolden', (does not need glut)
# (make gmolden)
#
LIBSOGL = -lglut -lGLU -lGL -lXmu -lX11 -lm
#
# on linux :
#
#LIBSG = -L/usr/X11R6/lib -lglut -lGLU -lGL -lXmu -lX11 -lm
#
# on linux : sometimes you also need the gdk library:
#
#LIBSG = -L/usr/X11R6/lib -lgdk -lglut -lGLU -lGL -lXmu -lX11 -lm
#
# on linux with older Mesa installations try:
#
#LIBSG = -L/usr/X11R6/lib -lglut -lMesaGLU -lMesaGL -lXmu -lXi -lX11 -lm
#
# MacOS X "Panther" OpenGL implementation
# Needs Xcode tools
#
#LIBSG = -L/usr/X11R6/lib -framework GLUT -framework OpenGL -framework Cocoa
#
# From fred arnold, also OS-X
#
#LIBSG = -L/usr/X11R6/lib -Wl,-framework -Wl,GLUT -Wl,-framework -Wl,OpenGL -Wl,-framework -Wl,Cocoa -lGLU -lGL -lXmu -lX11 -lm

all:	molden gmolden ambfor/ambfor ambfor/ambmd surf/surf docker/docker $(EXTEN)
src/xwin.o:	src/xwin.c src/rots.h
src/xwingl.o:	src/xwin.c src/rots.h

molden:	$(OBJS) src/mpdum.o src/xwin.o 
	$(LDR) -o molden $(OBJS) src/mpdum.o src/xwin.o $(LIBS)
	mv molden bin/molden

gmolden:	$(OBJS) src/mpdum.o src/xwingl.o 
	$(LDR) -fno-builtin -o gmolden $(OBJS) src/mpdum.o src/xwingl.o $(LIBSG)
	mv gmolden bin/gmolden

ambfor/ambfor:	src/ambfor/*.f src/ambfor/*.c
	$(MAKE) -C src/ambfor FC=${FC} LDR="${LDR}" EXT="${EXT}" FFLAGS="$(FFLAGS)"
	mv src/ambfor/ambfor bin/ambfor

ambfor/ambmd:	src/ambfor/*.f src/ambfor/*.c
	$(MAKE) -C src/ambfor ambmd FC=${FC} LDR="${LDR}" EXT="${EXT}" FFLAGS="$(FFLAGS)"
	mv src/ambfor/ambmd bin/ambmd

surf/surf:	src/surf/*.h src/surf/*.c
	$(MAKE) -C src/surf depend 
	$(MAKE) -C src/surf EXT="${EXT}"
	mv src/surf/surf bin/surf

docker/docker:	docker/*.f docker/*.c

	$(MAKE) -C docker 

# noxwin will not work as long as the old ocglbck calls arent in dummys

noxwin:	$(OBJS) $(DOBJ) src/mpdum.o
	$(LDR) -o molden $(OBJS) $(DOBJ) src/mpdum.o -lm
	mv molden bin/molden.noxwin

# This version allows the fitting of multipole moments to the electrostatic
# pontential

molden.mpfit:	$(OBJS) src/mpolefit.o src/xwinmp.o
	$(LDR) -o molden $(OBJS) src/mpolefit.o src/xwinmp.o $(LIBS)
	mv molden bin/molden.mpfit

src/xwinmp.o:	src/xwin.c
	$(CC) $(CFLAGS) -DMPFIT src/xwin.c
	mv src/xwin.o src/xwinmp.o

src/xwingl.o:	src/xwin.c
	$(CC) $(CFLAGS) -g -DDOGL -c src/xwin.c -o src/xwingl.o

unmullik:	src/unmullik.o
	$(LDR) -o bin/unmullik src/unmullik.o

# short_wrl removes redundant vertices from molden's VRML2 files
# with the courtesy of Andreas Klamt of COSMOSlogic
#
short_wrl:	src/short_wrl.o
	$(LDR) -o bin/short_wrl src/short_wrl.o

# conversion of CADPAC output to molden format

cad2mol:	src/cad2mol.o
	$(LDR) -o bin/cad2mol src/cad2mol.o

clean:
	rm -f src/$(OBJS) src/mpdum.o src/xwin.o src/xwingl.o bin/molden bin/gmolden bin/ambfor bin/ambmd bin/surf src/ambfor/*.o src/surf/*.o docker/*.o

exten:
ifeq ("/usr/bin/gio", "$(shell which gio)")
	utils/register_extension_gio.sh
else
	utils/register_extension.sh
endif

exten2:
	utils/register_extension.sh /usr/local/bin

install:	$(EXTENZ)
	sudo install -t /usr/local/bin -m 755 bin/molden bin/gmolden bin/ambfor bin/ambmd bin/surf
