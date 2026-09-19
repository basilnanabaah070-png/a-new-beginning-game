CA65 := ca65
LD65 := ld65
BUILD := build

all: $(BUILD)/a-new-beginning.nes

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/main.o: src/main.s | $(BUILD)
	$(CA65) -g -o $@ $<

$(BUILD)/a-new-beginning.nes: $(BUILD)/main.o linker.cfg
	$(LD65) -C linker.cfg -o $@ $(BUILD)/main.o

clean:
	rm -rf $(BUILD)

.PHONY: all clean
