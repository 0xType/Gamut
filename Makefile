FONT_NAME = ZxGamut
WEIGHTS = Thin ExtraLight Light Regular Medium SemiBold Bold ExtraBold Black
SOURCE_DIR = sources
MAIN_GLYPHS_FILE = $(SOURCE_DIR)/$(FONT_NAME).glyphspackage
OUTPUT_DIR = fonts
OUTPUT_STATIC_DIR = $(OUTPUT_DIR)/static
OUTPUT_VARIABLE_DIR = $(OUTPUT_DIR)/variable
VF_SUFFIX = -Variable
WOFF2_DIR = woff2

setup:
	pip install -r requirements.txt
	if [ ! -e $(WOFF2_DIR) ]; then $(MAKE) setup-woff2; fi

setup-woff2:
	git clone --recursive https://github.com/google/woff2.git $(WOFF2_DIR)
	cd $(WOFF2_DIR) && make clean all

.PHONY: build
build:
	$(MAKE) clean
	$(MAKE) compile-all

compile-static: $(MAIN_GLYPHS_FILE)
	fontmake -a -g $(MAIN_GLYPHS_FILE) -i --output-dir $(OUTPUT_STATIC_DIR)

compile-variable: $(MAIN_GLYPHS_FILE)
	fontmake -a -g $(MAIN_GLYPHS_FILE) -o variable --output-path $(OUTPUT_VARIABLE_DIR)/$(FONT_NAME)$(VF_SUFFIX).ttf

compile-woff2: compile-static compile-variable
	@for weight in $(WEIGHTS); do \
		./woff2/woff2_compress $(OUTPUT_STATIC_DIR)/$(FONT_NAME)-$$weight.ttf; \
	done
	./woff2/woff2_compress $(OUTPUT_VARIABLE_DIR)/$(FONT_NAME)$(VF_SUFFIX).ttf

compile-all: $(MAIN_GLYPHS_FILE)
	$(MAKE) compile-woff2

.PHONY: clean
clean:
	if [ -e $(OUTPUT_DIR) ]; then rm -rf $(OUTPUT_DIR); fi

install-variable: $(OUTPUT_VARIABLE_DIR)/$(FONT_NAME)VF.ttf
	cp $(OUTPUT_VARIABLE_DIR)/$(FONT_NAME)VF.ttf $(HOME)/Library/Fonts

.PHONY: install
install:
	$(MAKE) build
	$(MAKE) install-variable
