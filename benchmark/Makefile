.PHONY: all test benchmark clean

BYTECODE_DIR := ../out
BENCHMARKS_DIR := ./benchmark-results
DEFAULT_BENCHMARK_FILEPATH := ./snapshots/ERC20Benchmark.json
TARGETS := solidity vyper yul yulp fe

BYTECODE_FILES_solidity := ERC20_no_opt.json ERC20_ir.json ERC20_opt.json
BYTECODE_FILES_vyper := ERC20_no_opt.json ERC20_opt_codesize.json ERC20_opt_gas.json
BYTECODE_FILES_yul := ERC20_no_opt.json ERC20_opt.json
BYTECODE_FILES_yulp := ERC20.json
BYTECODE_FILES_fe := ERC20.json

# ========== TEST ==========

test: $(addprefix test-,$(TARGETS))

VERBOSITY_FLAG := --quiet
ifeq ($(VERBOSE),true)
  VERBOSITY_FLAG := -vvv
endif

define RUN_TESTS
	@set -e; \
	for file in $(2); do \
		printf "Running tests for $(BYTECODE_DIR)/$(1)/$$$$file "; \
		BYTECODE_PATH=$(BYTECODE_DIR)/$(1)/$$$$file forge test ./test/ERC20.t.sol --fail-fast $(VERBOSITY_FLAG); \
		echo " " ; \
	done
endef

$(foreach t,$(TARGETS),$(eval test-$(t): ; $(call RUN_TESTS,$(t),$(BYTECODE_FILES_$(t)))))

# ========== BENCHMARK ==========

benchmark: $(addprefix benchmark-,$(TARGETS))

define RUN_BENCHMARKS
	@set -e; \
	for file in $(2); do \
		printf "Running benchmarks for $(BYTECODE_DIR)/$(1)/$$$$file "; \
		BYTECODE_PATH=$(BYTECODE_DIR)/$(1)/$$$$file forge test ./test/ERC20Benchmark.t.sol --fail-fast --quiet; \
		mv $(DEFAULT_BENCHMARK_FILEPATH) $(BENCHMARKS_DIR)/$(1)/$$$$file; \
		echo " " ; \
	done
endef

$(foreach t,$(TARGETS),$(eval benchmark-$(t): | $(BENCHMARKS_DIR)/$(t); $(call RUN_BENCHMARKS,$(t),$(BYTECODE_FILES_$(t)))))

$(BENCHMARKS_DIR)/%:
	mkdir -p $@

# ========== CLEAN ==========

clean: $(addprefix clean-,$(TARGETS))

$(foreach t,$(TARGETS),$(eval clean-$(t): ; rm -rf $(BENCHMARKS_DIR)/$(t)))
