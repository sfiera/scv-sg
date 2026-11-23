KICAD_CLI ?= docker run --platform linux/amd64 -v $(CURDIR):/src -w /src -u root kicad/kicad:10.0 kicad-cli

.PHONY: all
all: scv-sg.zip doc/pcb.png doc/schematic.png

%.zip: %.kicad_pcb
	rm -Rf $*/ $@
	$(KICAD_CLI) pcb export gerbers $< --output $*
	$(KICAD_CLI) pcb export drill $< --output $*
	zip -r $@ $*/

doc/pcb.png: scv-sg.kicad_pcb
	$(KICAD_CLI) pcb render $< --output $@ --width 800 --height 400 --zoom 1.9 --side top --perspective

doc/schematic.png: scv-sg.kicad_sch
	$(KICAD_CLI) sch export svg $< --exclude-drawing-sheet --no-background-color
	rsvg-convert scv-sg.svg -o scv-sg.png -b white -d300 -p300
	magick scv-sg.png -trim +repage -bordercolor white -border 50x50 $@

.PHONY: clean
clean:
	rm -Rf scv-sg scv-sg.zip scv-sg.png scv-sg.svg
