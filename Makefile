# ========== ALL ==========
all: solidity vyper yul yulp fe

# ========== SOLIDITY ==========
SOL_SRC_FILE := ERC20.sol
SOL_SRC_DIR := code/solidity
SOL_FILEPATH := $(SOL_SRC_DIR)/$(SOL_SRC_FILE)
SOL_O_DIR := code/compiled/solidity
SOL_O_FILES := \
	$(SOL_O_DIR)/ERC20_no_opt.json \
	$(SOL_O_DIR)/ERC20_ir.json \
	$(SOL_O_DIR)/ERC20_opt.json

.PHONY: solidity
solidity: $(SOL_O_FILES)

$(SOL_O_DIR)/ERC20_%.json: $(SOL_SRC_DIR)/*.sol
	@case "$*" in \
		no_opt) \
			solc --combined-json bin $(SOL_FILEPATH) | \
			jq -r '.contracts["$(SOL_FILEPATH):ERC20"]' > $@ ;; \
		ir) \
			solc --via-ir --optimize --optimize-runs 200 --combined-json bin $(SOL_FILEPATH) | \
			jq -r '.contracts["$(SOL_FILEPATH):ERC20"]' > $@ ;; \
		opt) \
			solc --optimize --optimize-runs 100000 --combined-json bin $(SOL_FILEPATH) | \
			jq -r '.contracts["$(SOL_FILEPATH):ERC20"]' > $@ ;; \
		*) \
			echo "Unknown target suffix: $*" >&2; \
			exit 1 ;; \
	esac

# ========== VYPER ==========
VYP_SRC_FILE := ERC20.vy
VYP_SRC_DIR := code/vyper
VYP_O_DIR := code/compiled/vyper
VYP_O_FILES := \
	$(VYP_O_DIR)/ERC20_no_opt.json \
	$(VYP_O_DIR)/ERC20_opt_codesize.json \
	$(VYP_O_DIR)/ERC20_opt_gas.json

.PHONY: vyper
vyper: $(VYP_O_FILES)

$(VYP_O_DIR)/ERC20_%.json: $(VYP_SRC_DIR)/$(VYP_SRC_FILE)
	@case "$*" in \
		no_opt) \
			vyper $< --no-optimize | cut -c 3- | \
			jq -R --slurp '{bin: (.| sub("\n$$"; ""))}' > $@ ;; \
		opt_codesize) \
			vyper $< --optimize codesize | cut -c 3- | \
			jq -R --slurp '{bin: (.| sub("\n$$"; ""))}' > $@ ;; \
		opt_gas) \
			vyper $< | cut -c 3- | \
			jq -R --slurp '{bin: (.| sub("\n$$"; ""))}' > $@ ;; \
		*) \
			echo "Unknown target suffix: $*" >&2; \
			exit 1 ;; \
	esac

# ========== YUL ==========
YUL_SRC_FILE := ERC20.yul
YUL_SRC_DIR := code/yul
YUL_O_DIR := code/compiled/yul
YUL_O_FILES := \
	$(YUL_O_DIR)/ERC20_no_opt.json \
	$(YUL_O_DIR)/ERC20_opt.json

.PHONY: yul
yul: $(YUL_O_FILES)

$(YUL_O_DIR)/ERC20_%.json: $(YUL_SRC_DIR)/$(YUL_SRC_FILE)
	@case "$*" in \
		no_opt) \
			solc --strict-assembly --bin $< | \
			grep -A 1 "Binary representation:" | tail -n 1 | \
			jq -R --slurp '{bin: (.| sub("\n$$"; ""))}' > $@ ;; \
		opt) \
			solc --strict-assembly --optimize --bin $< | \
			grep -A 1 "Binary representation:" | tail -n 1 | \
			jq -R --slurp '{bin: (.| sub("\n$$"; ""))}' > $@ ;; \
		*) \
			echo "Unknown target suffix: $*" >&2; \
			exit 1 ;; \
	esac

# ========== YULP ==========
YULP_SRC_FILE := ERC20.yulp
YULP_SRC_DIR := code/yulp
YULP_O_DIR := code/compiled/yulp
YULP_O_FILES := \
	$(YULP_O_DIR)/ERC20.json \

.PHONY: yulp
yulp: $(YULP_O_FILES)

$(YULP_O_DIR)/ERC20.json: $(YULP_SRC_DIR)/$(YULP_SRC_FILE)
	@node $(YULP_SRC_DIR)/compile.js && \
	solc --strict-assembly --bin $(YULP_O_DIR)/ir_ERC20.yul | \
	grep -A 1 "Binary representation:" | tail -n 1 | \
	jq -R --slurp '{bin: (.| sub("\n$$"; ""))}' > $@;

# ========== FE ==========
FE_SRC_FILE := ERC20.fe
FE_SRC_DIR := code/fe
FE_O_DIR := code/compiled/fe
FE_O_FILES := \
	$(FE_O_DIR)/ERC20.json \

.PHONY: fe
fe: $(FE_O_FILES)

$(FE_O_DIR)/ERC20.json: $(FE_SRC_DIR)/$(FE_SRC_FILE)
	@fe build --overwrite -o $(FE_O_DIR) -e bytecode $< && \
	jq -R --slurp '{bin: .}' $(FE_O_DIR)/ERC20/ERC20.bin  > $@;

# ========== CLEAN ==========
clean-solidity:
	rm -f $(SOL_O_FILES)

clean-vyper:
	rm -f $(VYP_O_FILES)

clean-yul:
	rm -f $(YUL_O_FILES)

clean-yulp:
	rm -f $(YULP_O_FILES)

clean-fe:
	rm -f $(FE_O_FILES)

.PHONY: clean
clean: clean-solidity clean-vyper clean-yul clean-yulp clean-fe
