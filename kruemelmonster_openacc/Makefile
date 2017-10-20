INCLUDES  := 
CXXFLAGS := -O2 -W -Wall -fopenacc
CPPFLAGS := -std=c++17
LDFLAGS := -Wl,--as-needed
LIBRARIES := -lGL -lglut -lgomp

all: build

build: kruemelmonster_openacc

kruemelmonster_openacc.o:kruemelmonster_openacc.cpp
	$(EXEC) $(CXX) $(INCLUDES) $(CPPFLAGS) $(CXXFLAGS) -o $@ -c $^ $(LIBRARIES)

kruemelmonster_openacc: kruemelmonster_openacc.o
	$(EXEC) $(CXX) $(LDFLAGS) -o $@ $+ $(LIBRARIES)

run: build
	$(EXEC) ./kruemelmonster_openacc

clean:
	rm -f kruemelmonster_openacc kruemelmonster_openacc.o

clobber: clean
