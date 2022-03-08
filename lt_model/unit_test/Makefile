TARGET = test_main
CXX = g++

FLAGS = -I/home/wftseng/systemc-2.3.2/include -std=c++11
LIBS = -L/home/wftseng/systemc-2.3.2/lib-linux64 -lsystemc
#LIBS = -L $(SYSTEMC_HOME)/lib-macosx64 -lsystemc
OBJS = test_c_queue_engine.o c_queue_engine.o constant.o
OBJS_DIR = $(addprefix obj/,$(OBJS))

test_main: $(OBJS_DIR)
	$(CXX) $(FLAGS) $(LIBS) test_main.cpp $^ -o $(TARGET) 

obj/%.o: %.cpp
	$(CXX) $(FLAGS) -o $@ -c $^

obj/c_queue_engine.o: ../c_queue_engine.cpp
	$(CXX) $(FLAGS) -o ./obj/c_queue_engine.o -c ../c_queue_engine.cpp

obj/constant.o: ../constant.cpp
	$(CXX) $(FLAGS) -o ./obj/constant.o -c ../constant.cpp

.PHONY: clean install

clean:
	rm -f $(TARGET)
	rm -f obj/*.o

install:
	cp $(TARGET) ../
