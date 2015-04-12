# Makefile
#
# Copyright (c) 2013, 2015, 2016 Jörgen Grahn
# All rights reserved.

GAMEDIR=/usr/games
GAMEUID=games

SHELL=/bin/bash

.PHONY: all
all: nethack
all: recover
all: levels.tar
all: data.tar

CC=gcc
CPPFLAGS=-Iinclude
CFLAGS=-Os -g -std=gnu89 -Wall -Wno-comment

nethack: sys/unix/unixmain.o libnethack.a libunix.a libwin.a
	$(CC) $(CFLAGS) -o $@ $< -L. -lnethack -lunix -lwin -lnethack -lmakedefs \
	-lncurses -lXaw -lXmu -lXext -lXt -lX11 -lXpm

recover: util/recover.o
	$(CC) $(CFLAGS) -o $@ $<

makedefs: util/makedefs.o libmakedefs.a
	$(CC) $(CFLAGS) -o $@ $< -L. -lmakedefs

tilemap: win/share/tilemap.o
	$(CC) $(CFLAGS) -o $@ $<

dgn_comp: util/dgn_main.o libdgncomp.a
	$(CC) $(CFLAGS) -o $@ $< -L. -ldgncomp

lev_comp: util/lev_main.o liblevcomp.a
	$(CC) $(CFLAGS) -o $@ $< -L. -llevcomp

libmakedefs.a: src/monst.o
libmakedefs.a: src/objects.o
	$(AR) -r $@ $^

liblevcomp.a: lev_yacc.o
liblevcomp.a: lev_lex.o
liblevcomp.a: src/alloc.o
liblevcomp.a: util/panic.o
liblevcomp.a: src/drawing.o
liblevcomp.a: src/decl.o
liblevcomp.a: src/monst.o
liblevcomp.a: src/objects.o
	$(AR) -r $@ $^

libdgncomp.a: dgn_yacc.o
libdgncomp.a: dgn_lex.o
libdgncomp.a: src/alloc.o
libdgncomp.a: util/panic.o
	$(AR) -r $@ $^

include/pm.h: makedefs
	(cd util && ../makedefs -p)
include/onames.h: makedefs
	(cd util && ../makedefs -o)
dat/options include/date.h: makedefs
	(cd util && ../makedefs -v)
src/monstr.c: makedefs
	(cd util && ../makedefs -m)
src/tile.c: tilemap
	(cd src && ../tilemap)
include/vis_tab.h src/vis_tab.c: makedefs
	(cd util && ../makedefs -z)

dgn_yacc.c dgn_comp.h: util/dgn_comp.y
	bison -d util/dgn_comp.y
	mv dgn_comp.tab.c dgn_yacc.c
	mv dgn_comp.tab.h dgn_comp.h
lev_yacc.c lev_comp.h: util/lev_comp.y
	bison -d util/lev_comp.y
	mv lev_comp.tab.c lev_yacc.c
	mv lev_comp.tab.h lev_comp.h
dgn_lex.c: util/dgn_comp.l
	flex -o $@ $^
lev_lex.c: util/lev_comp.l
	flex -o $@ $^

.PHONY: generated
generated: include/pm.h
generated: include/onames.h
generated: include/date.h
generated: include/vis_tab.h
generated: src/vis_tab.c
generated: src/monstr.c
generated: src/tile.c
generated: dat/options

# Problematic part. Lots of people need these, and since they're
# generated they are absent when first needed ...
# The pattern part doesn't appear to work.

src/%.c: include/onames.h include/pm.h
src/version.c: include/date.h

src/vis_tab.o: include/vis_tab.h
src/vision.o: include/vis_tab.h

sys/unix/unixmain.o: include/onames.h
sys/unix/unixmain.o: include/pm.h
# this rule doesn't work, for some reason:
sys/unix/%.o: include/onames.h include/pm.h

.PHONY: generators
generators: makedefs
generators: tilemap
generators: dgn_comp
generators: lev_comp

libnethack.a: src/allmain.o   src/eat.o        src/mkroom.o     src/restore.o
libnethack.a: src/alloc.o     src/end.o        src/mondata.o    src/rip.o
libnethack.a: src/apply.o     src/engrave.o    src/monmove.o    src/rnd.o
libnethack.a: src/artifact.o  src/exper.o      src/mon.o        src/role.o
libnethack.a: src/attrib.o    src/explode.o    src/monstr.o     src/rumors.o
libnethack.a: src/ball.o      src/extralev.o   src/mplayer.o    src/save.o
libnethack.a: src/bones.o     src/files.o      src/mthrowu.o    src/shknam.o
libnethack.a: src/botl.o      src/fountain.o   src/muse.o       src/shk.o
libnethack.a: src/cmd.o       src/hacklib.o    src/music.o      src/sit.o
libnethack.a: src/dbridge.o   src/hack.o       src/objnam.o     src/sounds.o
libnethack.a: src/decl.o      src/invent.o     src/o_init.o     src/spell.o
libnethack.a: src/detect.o    src/light.o      src/options.o    src/sp_lev.o
libnethack.a: src/dig.o       src/lock.o       src/pager.o      src/steal.o
libnethack.a: src/display.o   src/mail.o       src/pickup.o     src/steed.o
libnethack.a: src/dlb.o       src/makemon.o    src/pline.o      src/teleport.o
libnethack.a: src/dogmove.o   src/mapglyph.o   src/polyself.o   src/timeout.o
libnethack.a: src/dog.o       src/mcastu.o     src/potion.o     src/topten.o
libnethack.a: src/dokick.o    src/mhitm.o      src/pray.o       src/track.o
libnethack.a: src/do_name.o   src/mhitu.o      src/priest.o     src/trap.o
libnethack.a: src/do.o        src/minion.o     src/quest.o      src/uhitm.o
libnethack.a: src/dothrow.o   src/mklev.o      src/questpgr.o   src/u_init.o
libnethack.a: src/do_wear.o   src/mkmap.o      src/read.o       src/vault.o
libnethack.a: src/drawing.o   src/mkmaze.o     src/rect.o       src/weapon.o
libnethack.a: src/dungeon.o   src/mkobj.o      src/region.o     src/were.o
libnethack.a: src/wield.o
libnethack.a: src/windows.o
libnethack.a: src/vision.o
libnethack.a: src/vis_tab.o
libnethack.a: src/wizard.o
libnethack.a: src/worm.o
libnethack.a: src/worn.o
libnethack.a: src/write.o
libnethack.a: src/zap.o
libnethack.a: src/version.o
libnethack.a: src/sys.o
	$(AR) -r $@ $^

libwin.a: win/tty/getline.o
libwin.a: win/tty/termcap.o
libwin.a: win/tty/topl.o
libwin.a: win/tty/wintty.o
libwin.a: win/X11/Window.o
libwin.a: win/X11/dialogs.o
libwin.a: win/X11/winX.o
libwin.a: win/X11/winmap.o
libwin.a: win/X11/winmenu.o
libwin.a: win/X11/winmesg.o
libwin.a: win/X11/winmisc.o
libwin.a: win/X11/winstat.o
libwin.a: win/X11/wintext.o
libwin.a: win/X11/winval.o
libwin.a: src/tile.o
	$(AR) -r $@ $^

libunix.a: sys/unix/unixres.o
libunix.a: sys/unix/unixunix.o
libunix.a: sys/share/unixtty.o
libunix.a: sys/share/ioctl.o
libunix.a: sys/share/posixregex.o
	$(AR) -r $@ $^

levels.tar: air.lev       Hea-fila.lev  Mon-strt.lev  soko3-2.lev
levels.tar: Arc-fila.lev  Hea-filb.lev  oracle.lev    soko4-1.lev
levels.tar: Arc-filb.lev  Hea-goal.lev  orcus.lev     soko4-2.lev
levels.tar: Arc-goal.lev  Hea-loca.lev  Pri-fila.lev  Tou-fila.lev
levels.tar: Arc-loca.lev  Hea-strt.lev  Pri-filb.lev  Tou-filb.lev
levels.tar: Arc-strt.lev  juiblex.lev   Pri-goal.lev  Tou-goal.lev
levels.tar: asmodeus.lev  Kni-fila.lev  Pri-loca.lev  Tou-loca.lev
levels.tar: astral.lev    Kni-filb.lev  Pri-strt.lev  Tou-strt.lev
levels.tar: baalz.lev     Kni-goal.lev  Ran-fila.lev  tower1.lev
levels.tar: Bar-fila.lev  Kni-loca.lev  Ran-filb.lev  tower2.lev
levels.tar: Bar-filb.lev  Kni-strt.lev  Ran-goal.lev  tower3.lev
levels.tar: Bar-goal.lev  knox.lev      Ran-loca.lev  Val-fila.lev
levels.tar: Bar-loca.lev  medusa-1.lev  Ran-strt.lev  Val-filb.lev
levels.tar: Bar-strt.lev  medusa-2.lev  Rog-fila.lev  Val-goal.lev
levels.tar: bigrm-1.lev   minefill.lev  Rog-filb.lev  valley.lev
levels.tar: bigrm-2.lev   minend-1.lev  Rog-goal.lev  Val-loca.lev
levels.tar: bigrm-3.lev   minend-2.lev  Rog-loca.lev  Val-strt.lev
levels.tar: bigrm-4.lev   minend-3.lev  Rog-strt.lev  water.lev
levels.tar: bigrm-5.lev   minetn-1.lev  Sam-fila.lev  wizard1.lev
levels.tar: castle.lev    minetn-2.lev  Sam-filb.lev  wizard2.lev
levels.tar: Cav-fila.lev  minetn-3.lev  Sam-goal.lev  wizard3.lev
levels.tar: Cav-filb.lev  minetn-4.lev  Sam-loca.lev  Wiz-fila.lev
levels.tar: Cav-goal.lev  minetn-5.lev  Sam-strt.lev  Wiz-filb.lev
levels.tar: Cav-loca.lev  minetn-6.lev  sanctum.lev   Wiz-goal.lev
levels.tar: Cav-strt.lev  minetn-7.lev  soko1-1.lev   Wiz-loca.lev
levels.tar: earth.lev     Mon-fila.lev  soko1-2.lev   Wiz-strt.lev
levels.tar: fakewiz1.lev  Mon-filb.lev  soko2-1.lev
levels.tar: fakewiz2.lev  Mon-goal.lev  soko2-2.lev
levels.tar: fire.lev      Mon-loca.lev  soko3-1.lev
	tar cf $@ $^

Arc-strt.lev Arc-loca.lev Arc-goal.lev Arc-fila.lev Arc-filb.lev: dat/Arch.des lev_comp
	./lev_comp $<
Bar-strt.lev Bar-loca.lev Bar-goal.lev Bar-fila.lev Bar-filb.lev: dat/Barb.des lev_comp
	./lev_comp $<
Cav-strt.lev Cav-loca.lev Cav-goal.lev Cav-fila.lev Cav-filb.lev: dat/Caveman.des lev_comp
	./lev_comp $<
Hea-strt.lev Hea-loca.lev Hea-goal.lev Hea-fila.lev Hea-filb.lev: dat/Healer.des lev_comp
	./lev_comp $<
Kni-strt.lev Kni-loca.lev Kni-goal.lev Kni-fila.lev Kni-filb.lev: dat/Knight.des lev_comp
	./lev_comp $<
Mon-strt.lev Mon-loca.lev Mon-goal.lev Mon-fila.lev Mon-filb.lev: dat/Monk.des lev_comp
	./lev_comp $<
Pri-strt.lev Pri-loca.lev Pri-goal.lev Pri-fila.lev Pri-filb.lev: dat/Priest.des lev_comp
	./lev_comp $<
Ran-strt.lev Ran-loca.lev Ran-goal.lev Ran-fila.lev Ran-filb.lev: dat/Ranger.des lev_comp
	./lev_comp $<
Rog-strt.lev Rog-loca.lev Rog-goal.lev Rog-fila.lev Rog-filb.lev: dat/Rogue.des lev_comp
	./lev_comp $<
Sam-strt.lev Sam-loca.lev Sam-goal.lev Sam-fila.lev Sam-filb.lev: dat/Samurai.des lev_comp
	./lev_comp $<
Tou-strt.lev Tou-loca.lev Tou-goal.lev Tou-fila.lev Tou-filb.lev: dat/Tourist.des lev_comp
	./lev_comp $<
Val-strt.lev Val-loca.lev Val-goal.lev Val-fila.lev Val-filb.lev: dat/Valkyrie.des lev_comp
	./lev_comp $<
Wiz-strt.lev Wiz-loca.lev Wiz-goal.lev Wiz-fila.lev Wiz-filb.lev: dat/Wizard.des lev_comp
	./lev_comp $<
bigrm-1.lev bigrm-2.lev bigrm-3.lev bigrm-4.lev bigrm-5.lev: dat/bigroom.des lev_comp
	./lev_comp $<
castle.lev: dat/castle.des lev_comp
	./lev_comp $<
earth.lev air.lev fire.lev water.lev astral.lev: dat/endgame.des lev_comp
	./lev_comp $<
valley.lev juiblex.lev orcus.lev asmodeus.lev baalz.lev sanctum.lev: dat/gehennom.des lev_comp
	./lev_comp $<
knox.lev: dat/knox.des lev_comp
	./lev_comp $<
medusa-1.lev medusa-2.lev: dat/medusa.des lev_comp
	./lev_comp $<
minefill.lev minetn-1.lev minetn-2.lev minetn-3.lev minetn-4.lev minetn-5.lev minetn-6.lev minetn-7.lev minend-1.lev minend-2.lev minend-3.lev: dat/mines.des lev_comp
	./lev_comp $<
oracle.lev: dat/oracle.des lev_comp
	./lev_comp $<
soko4-1.lev soko4-2.lev soko3-1.lev soko3-2.lev soko2-1.lev soko2-2.lev soko1-1.lev soko1-2.lev: dat/sokoban.des lev_comp
	./lev_comp $<
tower1.lev tower2.lev tower3.lev: dat/tower.des lev_comp
	./lev_comp $<
wizard1.lev wizard2.lev wizard3.lev fakewiz1.lev fakewiz2.lev: dat/yendor.des lev_comp
	./lev_comp $<

data.tar: dat/cmdhelp
data.tar: dat/help
data.tar: dat/hh
data.tar: dat/wizhelp
data.tar: dat/opthelp
data.tar: dat/history
data.tar: dat/license
data.tar: dat/data
data.tar: dat/dungeon
data.tar: dat/options
data.tar: dat/oracles
data.tar: dat/quest.dat
data.tar: dat/rip.xpm
data.tar: dat/rumors
data.tar: dat/sysconf
	tar cf $@ $^

dat/data: dat/data.base makedefs
	cd dat && ../makedefs -d

dat/dungeon.pdf: dat/dungeon.def makedefs
	cd dat && ../makedefs -e

dat/dungeon: dat/dungeon.pdf dgn_comp
	cd dat && ../dgn_comp dungeon.pdf

dat/oracles: dat/oracles.txt makedefs
	cd dat && ../makedefs -h

dat/quest.dat: dat/quest.txt makedefs
	cd dat && ../makedefs -q

dat/rip.xpm: win/X11/rip.xpm
	cp $< $@

dat/rumors: dat/rumors.tru dat/rumors.fal
	cd dat && ../makedefs -r

dat/sysconf: sys/unix/sysconf
	cp $< $@

.PHONY: install
install: sys/unix/nethack.sh
install: nethack
install: recover
install: levels.tar
install: data.tar
	install -d $(GAMEDIR)/{,lib}
	install -o $(GAMEUID) -d $(GAMEDIR)/lib/nethackdir
	install -o $(GAMEUID) sys/unix/nethack.sh $(GAMEDIR)/nethack
	install -o $(GAMEUID) nethack recover $(GAMEDIR)/lib/nethackdir
	chmod g+s $(GAMEDIR)/lib
	chmod u+s $(GAMEDIR)/lib/nethackdir/nethack
	tar -C $(GAMEDIR)/lib/nethackdir/ --strip-components=1 --no-same-{owner,permissions} -xf data.tar
	tar -C $(GAMEDIR)/lib/nethackdir/ --no-same-{owner,permissions} -xf levels.tar
	touch $(GAMEDIR)/lib/nethackdir/{logfile,xlogfile,perm,record}
	chown $(GAMEUID) $(GAMEDIR)/lib/nethackdir/{logfile,xlogfile,perm,record}
	install -d $(GAMEDIR)/lib/nethackdir/save

.PHONY: tags
tags: TAGS
TAGS:
	etags include/*.h {src,util}/*.[ch] sys/{share,unix}/*.[ch] win/{share,tty,X11}/*.[ch]

.PHONY: clean
clean:
	$(RM) nethack recover
	$(RM) makedefs tilemap dgn_comp lev_comp
	$(RM) lib{makedefs,levcomp,dgncomp}.a
	$(RM) lib{nethack,win,unix}.a
	$(RM) *.o src/*.o util/*.o sys/{share,unix}/*.o win/{share,tty,X11}/*.o
	$(RM) include/{vis_tab.h,pm.h,onames.h,date.h}
	$(RM) src/{monstr.c,vis_tab.c,tile.c}
	$(RM) dgn_yacc.c dgn_comp.h lev_yacc.c lev_comp.h dgn_lex.c lev_lex.c
	$(RM) dat/{data,dungeon.pdf,dungeon,options,oracles,quest.dat,rip.xpm,rumors,sysconf}
	$(RM) data.tar
	$(RM) levels.tar *.lev
	$(RM) -r dep

love:
	@echo "not war?"

# DO NOT DELETE

$(shell mkdir -p dep/{src,util}/ dep/sys/{share,unix}/ dep/win/{share,tty,X11}/)
DEPFLAGS=-MT $@ -MMD -MP -MF dep/$*.Td
COMPILE.c=$(CC) $(DEPFLAGS) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c

%.o: %.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<
	@mv dep/$*.{Td,d}

dep/src/%.d: ;
dep/util/%.d: ;
dep/sys/share/%.d: ;
dep/sys/unix/%.d: ;
dep/win/share/%.d: ;
dep/win/tty/%.d: ;
dep/win/X11/%.d: ;

-include dep/*.d
-include dep/src/*.d
-include dep/util/*.d
-include dep/sys/share/*.d
-include dep/sys/unix/*.d
-include dep/win/share/*.d
-include dep/win/tty/*.d
-include dep/win/X11/*.d
