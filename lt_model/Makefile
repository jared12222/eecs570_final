TARGET = main
CXX = g++

FLAGS = -I/home/wftseng/systemc-2.3.2/include
LIBS = -L/home/wftseng/systemc-2.3.2/lib-linux64 -lsystemc
#LIBS = -L $(SYSTEMC_HOME)/lib-macosx64 -lsystemc
OBJS = top.o c_queue_engine.o
OBJS_DIR = $(addprefix obj/,$(OBJS))

main: $(OBJS_DIR)
	$(CXX) $(FLAGS) $(LIBS) $^ main.cpp -o $(TARGET) 

obj/%.o: %.cpp
	$(CXX) $(FLAGS) -o $@ -c $^

.PHONY: clean install

clean:
	rm -f $(TARGET)
	rm -f obj/*.o

install:
	cp $(TARGET) ../
