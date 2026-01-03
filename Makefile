# Makefile for MIPS Processor Verilog Project

IVERILOG = iverilog
VVP = vvp
SRC_DIR = .
TEST_DIR = test
BUILD_DIR = build

MODULES = ALU_Control.v ALU.v \
          EX_MEM_Reg.v EX_PC_Calculation.v EX_Stage.v \
          ID_Control_Unit.v ID_EX_Reg.v ID_Register_File.v ID_Stage.v \
          IF_ID_Reg.v IF_Stage.v \
          MEM_Data_Memory.v MEM_Stage.v MEM_WB_Reg.v \
          WB_Stage.v \
          MIPS.v

MAIN_TEST = $(TEST_DIR)/MIPS_testbench.v
UNIT_TEST_OUTS = $(BUILD_DIR)/test_alu \
                 $(BUILD_DIR)/test_pc_calc \
                 $(BUILD_DIR)/test_ex_stage \
                 $(BUILD_DIR)/test_id_control \
                 $(BUILD_DIR)/test_id_stage \
                 $(BUILD_DIR)/test_if_stage

all: $(BUILD_DIR)/mips_test $(UNIT_TEST_OUTS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/mips_test: $(MODULES) $(MAIN_TEST) | $(BUILD_DIR)
	$(IVERILOG) -o $@ $(addprefix $(SRC_DIR)/, $(MODULES)) $(MAIN_TEST)

$(BUILD_DIR)/test_alu: ALU_Control.v ALU.v $(TEST_DIR)/test-ALU.v | $(BUILD_DIR)
	$(IVERILOG) -g2012 -o $@ $(SRC_DIR)/ALU_Control.v $(SRC_DIR)/ALU.v $(TEST_DIR)/test-ALU.v

$(BUILD_DIR)/test_pc_calc: EX_PC_Calculation.v $(TEST_DIR)/test-EX_PC_Calculation.v | $(BUILD_DIR)
	$(IVERILOG) -g2012 -o $@ $(SRC_DIR)/EX_PC_Calculation.v $(TEST_DIR)/test-EX_PC_Calculation.v

$(BUILD_DIR)/test_ex_stage: ALU_Control.v ALU.v EX_PC_Calculation.v EX_Stage.v $(TEST_DIR)/test-EX_Stage.v | $(BUILD_DIR)
	$(IVERILOG) -g2012 -o $@ $(SRC_DIR)/ALU_Control.v $(SRC_DIR)/ALU.v $(SRC_DIR)/EX_PC_Calculation.v $(SRC_DIR)/EX_Stage.v $(TEST_DIR)/test-EX_Stage.v

$(BUILD_DIR)/test_id_control: ID_Control_Unit.v $(TEST_DIR)/test-ID_Control_Unit.v | $(BUILD_DIR)
	$(IVERILOG) -g2012 -o $@ $(SRC_DIR)/ID_Control_Unit.v $(TEST_DIR)/test-ID_Control_Unit.v

$(BUILD_DIR)/test_id_stage: ID_Control_Unit.v ID_Register_File.v ID_Stage.v $(TEST_DIR)/test-ID_Stage.v | $(BUILD_DIR)
	$(IVERILOG) -g2012 -o $@ $(SRC_DIR)/ID_Control_Unit.v $(SRC_DIR)/ID_Register_File.v $(SRC_DIR)/ID_Stage.v $(TEST_DIR)/test-ID_Stage.v

$(BUILD_DIR)/test_if_stage: IF_Stage.v $(TEST_DIR)/test-IF_Stage.v | $(BUILD_DIR)
	$(IVERILOG) -g2012 -o $@ $(SRC_DIR)/IF_Stage.v $(TEST_DIR)/test-IF_Stage.v

run-main: $(BUILD_DIR)/mips_test
	$(VVP) $<

run-tests: $(UNIT_TEST_OUTS)
	@for test in $(UNIT_TEST_OUTS); do \
		echo "Running $$(basename $$test)..."; \
		$(VVP) $$test || true; \
		echo ""; \
	done

run-alu: $(BUILD_DIR)/test_alu
	$(VVP) $<

run-pc-calc: $(BUILD_DIR)/test_pc_calc
	$(VVP) $<

run-ex-stage: $(BUILD_DIR)/test_ex_stage
	$(VVP) $<

run-id-control: $(BUILD_DIR)/test_id_control
	$(VVP) $<

run-id-stage: $(BUILD_DIR)/test_id_stage
	$(VVP) $<

run-if-stage: $(BUILD_DIR)/test_if_stage
	$(VVP) $<

clean:
	rm -rf $(BUILD_DIR)

help:
	@echo "Targets:"
	@echo "  all          - Compile all tests"
	@echo "  run-main     - Compile and run main MIPS testbench"
	@echo "  run-tests    - Compile and run all unit tests"
	@echo "  run-alu      - Compile and run ALU test"
	@echo "  run-pc-calc  - Compile and run EX_PC_Calculation test"
	@echo "  run-ex-stage - Compile and run EX_Stage test"
	@echo "  run-id-control - Compile and run ID_Control_Unit test"
	@echo "  run-id-stage - Compile and run ID_Stage test"
	@echo "  run-if-stage - Compile and run IF_Stage test"
	@echo "  clean        - Remove build artifacts"
	@echo "  help         - Show this help"

.PHONY: all run-main run-tests run-alu run-pc-calc run-ex-stage run-id-control run-id-stage run-if-stage clean help
