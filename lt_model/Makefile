TARGET = bin/main
CXX = g++

FLAGS = -I/home/wftseng/systemc-2.3.2/include -std=c++11
LIBS = -L/home/wftseng/systemc-2.3.2/lib-linux64 -lsystemc
#LIBS = -L $(SYSTEMC_HOME)/lib-macosx64 -lsystemc
OBJS = clause_engine.o uc_queue_arbiter.o clause_switch.o latency_buffer_arbiter.o controller.o top.o
OBJS_DIR = $(addprefix obj/,$(OBJS))

bin/main: $(OBJS_DIR)
	$(CXX) $(FLAGS) $(LIBS) main.cpp $^ -o $(TARGET) 

obj/%.o: %.cpp
	$(CXX) $(FLAGS) -o $@ -c $^

# obj/clause_engine.o: ../clause_engine.cpp
# 	$(CXX) $(FLAGS) -o ./obj/clause_engine.o -c ../clause_engine.cpp

# obj/uc_queue_arbiter.o: ../uc_queue_arbiter.cpp
# 	$(CXX) $(FLAGS) -o ./obj/uc_queue_arbiter.o -c ../uc_queue_arbiter.cpp

# obj/clause_switch.o: ../clause_switch.cpp
# 	$(CXX) $(FLAGS) -o ./obj/clause_switch.o -c ../clause_switch.cpp

# obj/latency_buffer_arbiter.o: ../latency_buffer_arbiter.cpp
# 	$(CXX) $(FLAGS) -o ./obj/latency_buffer_arbiter.o -c ../latency_buffer_arbiter.cpp

# obj/constant.o: ../constant.cpp
# 	$(CXX) $(FLAGS) -o ./obj/constant.o -c ../constant.cpp

.PHONY: clean install

clean:
	rm -f obj/*.o
	rm -f bin/*

install:
	cp $(TARGET) ../
