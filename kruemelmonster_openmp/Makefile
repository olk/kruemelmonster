INCLUDES  := 
CXXFLAGS := -O2 -W -Wall -fopenmp
CPPFLAGS := -std=c++17
LDFLAGS := -Wl,--as-needed
LIBRARIES := -lGL -lglut -lgomp

all: build

build: kruemelmonster_openmp

kruemelmonster_openmp.o:kruemelmonster_openmp.cpp
	$(EXEC) $(CXX) $(INCLUDES) $(CPPFLAGS) $(CXXFLAGS) -o $@ -c $^ $(LIBRARIES)

kruemelmonster_openmp: kruemelmonster_openmp.o
	$(EXEC) $(CXX) $(LDFLAGS) -o $@ $+ $(LIBRARIES)

run: build
	$(EXEC) ./kruemelmonster_openmp

clean:
	rm -f kruemelmonster_openmp kruemelmonster_openmp.o

clobber: clean
