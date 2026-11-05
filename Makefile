CC = gcc
BUILD = build
TARGET = robotscript

all: $(TARGET)

$(TARGET): src/robotscript.y src/robotscript.l
	mkdir -p $(BUILD)
	bison -d -o $(BUILD)/robotscript.tab.c src/robotscript.y
	flex -o $(BUILD)/lex.yy.c src/robotscript.l
	$(CC) -I$(BUILD) -o $(TARGET) $(BUILD)/robotscript.tab.c $(BUILD)/lex.yy.c

run: $(TARGET)
	./$(TARGET) < examples/sample.txt

clean:
	rm -rf $(BUILD) $(TARGET) $(TARGET).exe

.PHONY: all run clean
