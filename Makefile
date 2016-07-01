#
# "Visolate" -- compute (Voronoi) PCB isolation routing toolpaths
#
# Copyright (C) 2016 Markus Hitter <mah@jump-ing.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

VERSION = 3.2

CLASS_SRC   = src
CLASS_BUILD = bin
JAR_BUILD   = releases

MANIFEST = $(CLASS_SRC)/Visolate.mf

# A useful command for finding required classes:
#   find /usr -name \*.jar 2>/dev/null | while read F; do \
#     jar -tvf "$F" | grep -i ParseException && echo "$F"; \
#   done
CLASSPATH  = /usr/share/java/commons-cli.jar
CLASSPATH += /usr/share/java/vecmath.jar
CLASSPATH += /usr/share/java/j3dcore.jar
CLASSPATH += /usr/share/java/j3dutils.jar

SOURCES  = $(wildcard $(CLASS_SRC)/visolate/*.java)
SOURCES += $(wildcard $(CLASS_SRC)/visolate/model/*.java)
SOURCES += $(wildcard $(CLASS_SRC)/visolate/misc/*.java)
SOURCES += $(wildcard $(CLASS_SRC)/visolate/processor/*.java)
SOURCES += $(wildcard $(CLASS_SRC)/visolate/simulator/*.java)
SOURCES += $(wildcard $(CLASS_SRC)/visolate/parser/*.java)

# Needed for single file compilation, only.
#CLASSES = $(subst $(CLASS_SRC),$(CLASS_BUILD),$(subst .java,.class,$(SOURCES)))

JAR_EXTRAS  = lib/commons-cli-1.2.jar
JAR_EXTRAS += lib/LICENSE.txt


.PHONY: all
.SUFFIXES:

all: $(JAR_BUILD)/visolate-$(VERSION).jar

# This works, but compiling a single file takes 5.5 seconds, almost as long as
# compiling all of them with one call (6.5 seconds), so this recipe isn't of
# much use.
# Note: '$(subst ,, )' equals a space.
$(CLASS_BUILD)/%.class: $(CLASS_SRC)/%.java
	javac -classpath $(subst $(subst ,, ),:,$(CLASSPATH)) \
    -sourcepath $(CLASS_SRC) -d $(CLASS_BUILD) $<

# Build everything, which happens reasonably fast.
$(JAR_BUILD)/visolate-$(VERSION).jar: Makefile $(SOURCES) $(MANIFEST)
$(JAR_BUILD)/visolate-$(VERSION).jar: $(JAR_EXTRAS)
	rm -rf $(CLASS_BUILD)
	javac -classpath $(subst $(subst ,, ),:,$(CLASSPATH)) \
    -d $(CLASS_BUILD) $(SOURCES)
	@for F in $(JAR_EXTRAS); do \
    D=$${F%/*}; \
    mkdir -p $(CLASS_BUILD)/$${D}; \
    echo cp $${F} $(CLASS_BUILD)/$${D}; \
    cp $${F} $(CLASS_BUILD)/$${D}; \
  done
	cd $(CLASS_BUILD) && jar -cfm ../$@ ../$(MANIFEST) .

.PHONY: run
run:
	cd bin && java -classpath .:$(subst $(subst ,, ),:,$(CLASSPATH)) visolate.Main
	java -classpath .:$(subst $(subst ,, ),:,$(CLASSPATH)) -jar $(JAR_BUILD)/visolate-$(VERSION).jar
