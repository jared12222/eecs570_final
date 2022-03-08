Implement loosely timed model based on TLM2.0

SystemC installation:
    - Download systemc source code below and unpacked it in a specific location (systemc2.3.2 or systemc2.3.3)
      https://www.accellera.org/downloads/standards/systemc
    - Follow the installation instruction in INSTALL file in the systemc2.3.2/
    - Add SC_CPLUSPLUS=201103L flags when enter ../configure command to enable c++11

Unit test compilation
    - cd to unit test folder
    - Replace the FLAGS & LIBS in the Makefile with your systemc library location
    - make & ./test_main or make clean before re-compilation


Trouble shooting
    - Error while loading shared libraries: libsystemc-2.3.2.so
      - Add export LD_LIBRARY_PATH=/home/{user}/systemc-2.3.2/lib-linux64:$LD_LIBRARY_PATH to your environment
