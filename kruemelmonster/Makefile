INCLUDES  := 
CXXFLAGS := -O2 -W -Wall
CPPFLAGS := -std=c++17
LDFLAGS := -Wl,--as-needed
LIBRARIES := -lGL -lglut

all: build

build: kruemelmonster

kruemelmonster.o:kruemelmonster.cpp
	$(EXEC) $(CXX) $(INCLUDES) $(CXXFLAGS) -o $@ -c $^ $(LIBRARIES)

kruemelmonster: kruemelmonster.o
	$(EXEC) $(CXX) $(LDFLAGS) -o $@ $+ $(LIBRARIES)

run: build
	$(EXEC) ./kruemelmonster

clean:
	rm -f kruemelmonster kruemelmonster.o

clobber: clean
