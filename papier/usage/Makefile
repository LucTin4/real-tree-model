.PHONY: examples

CC = pdflatex
BIBER = biber
CV_DIR = .
EXAMPLES_DIR = .
CV_SRCS = $(shell find $(CV_DIR) -name '*.tex')


cv.pdf: $(EXAMPLES_DIR)/main.tex $(CV_SRCS)
	$(CC) -output-directory=$(EXAMPLES_DIR) $<
	$(BIBER) $(EXAMPLES_DIR)/main
	$(CC) -output-directory=$(EXAMPLES_DIR) $<
