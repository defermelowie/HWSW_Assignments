# Makefile for linux
CC = gcc
CD = gdb
RM = rm -rf
MKDIR = mkdir

CFLAGS  = -Wall -Os --std=c99 -g
LDFLAGS = --std=gnu99

BUILDDIR = ../build
SOURCEDIR = ../src
TOOLSDIR = /mnt/c/Users/ldefe/Documents/IIW/HW_SW_Codesign/exercises/tools

SOURCES = main.c
SOURCES += $(filter-out $(SOURCEDIR)/firmware.c, $(wildcard $(SOURCEDIR)/*.c))
OBJECTS = $(patsubst $(SOURCEDIR)/%.c, ./%.o, $(SOURCES))
TARGET = main.out

################################################################

.PHONY: all

all: compile link clean run

compile:
	$(CC) -c $(CFLAGS) $(SOURCES)

link:
	$(CC) $(LDFLAGS) $(OBJECTS) -o $(TARGET)

clean:
	$(RM) *.o

run:
	./$(TARGET)

debug:
	$(CD) $(TARGET)
	

################################################################