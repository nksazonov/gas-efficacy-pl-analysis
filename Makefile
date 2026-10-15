.PHONY: all build test benchmark clean

all: compile# test benchmark

compile:
	@echo "Compiling source code..."
	@$(MAKE) -C src

# test:
# 	@echo "Running tests..."
# 	@$(MAKE) -C benchmark test

# benchmark:
# 	@echo "Running benchmarks..."
# 	@$(MAKE) -C benchmark benchmark

clean-compile:
	@$(MAKE) -C src clean

# clean-benchmark:
# 	@$(MAKE) -C benchmark clean

clean: clean-compile# clean-benchmark
