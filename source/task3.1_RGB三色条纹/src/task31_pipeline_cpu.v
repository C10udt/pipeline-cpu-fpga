`timescale 1ns / 1ps

// Five-stage MIPS-like pipeline CPU used by task 3.1.
// Supported instructions: ADD, SUB, AND, OR, SLT, ADDI, LUI, ORI,
// LW, SW, BEQ, BNE and J.  Includes forwarding, a load-use interlock
// and control-hazard flushing.
module task31_pipeline_cpu (
    input  wire        clk,
    input  wire        reset,
    output reg  [23:0] colour_top,
    output reg  [23:0] colour_middle,
    output reg  [23:0] colour_bottom,
    output reg         audio_enable,
    output wire [31:0] debug_pc
);
    localparam [31:0] STRIPE1_ADDR = 32'h0000_4000;
    localparam [31:0] STRIPE2_ADDR = 32'h0000_4004;
    localparam [31:0] STRIPE3_ADDR = 32'h0000_4008;
    localparam [31:0] AUDIO_ADDR   = 32'h0000_400C;

    localparam [2:0] ALU_ADD = 3'd0;
    localparam [2:0] ALU_SUB = 3'd1;
    localparam [2:0] ALU_AND = 3'd2;
    localparam [2:0] ALU_OR  = 3'd3;
    localparam [2:0] ALU_SLT = 3'd4;

    reg [31:0] pc;
    wire [31:0] fetched_instr;
    assign debug_pc = pc;

    task31_instruction_rom u_instruction_rom (
        .addr  (pc[9:2]),
        .instr (fetched_instr)
    );

    // ---- IF / ID pipeline registers ---------------------------------
    reg [31:0] if_id_instr;
    reg [31:0] if_id_pc4;

    // ---- ID stage decode --------------------------------------------
    wire [5:0] id_opcode = if_id_instr[31:26];
    wire [4:0] id_rs     = if_id_instr[25:21];
    wire [4:0] id_rt     = if_id_instr[20:16];
    wire [4:0] id_rd     = if_id_instr[15:11];
    wire [5:0] id_funct  = if_id_instr[5:0];
    wire [31:0] id_sign_imm = {{16{if_id_instr[15]}}, if_id_instr[15:0]};
    wire [31:0] id_zero_imm = {16'b0, if_id_instr[15:0]};
    wire [31:0] id_jump_target = {if_id_pc4[31:28], if_id_instr[25:0], 2'b00};

    reg        id_reg_dst;
    reg        id_alu_src;
    reg        id_mem_to_reg;
    reg        id_reg_write;
    reg        id_mem_read;
    reg        id_mem_write;
    reg        id_branch_eq;
    reg        id_branch_ne;
    reg        id_jump;
    reg        id_lui;
    reg        id_ori;
    reg [2:0]  id_alu_control;

    always @* begin
        id_reg_dst     = 1'b0;
        id_alu_src     = 1'b0;
        id_mem_to_reg  = 1'b0;
        id_reg_write   = 1'b0;
        id_mem_read    = 1'b0;
        id_mem_write   = 1'b0;
        id_branch_eq   = 1'b0;
        id_branch_ne   = 1'b0;
        id_jump        = 1'b0;
        id_lui         = 1'b0;
        id_ori         = 1'b0;
        id_alu_control = ALU_ADD;

        case (id_opcode)
            6'h00: begin   // R-type
                id_reg_dst   = 1'b1;
                id_reg_write = 1'b1;
                case (id_funct)
                    6'h20: id_alu_control = ALU_ADD;
                    6'h22: id_alu_control = ALU_SUB;
                    6'h24: id_alu_control = ALU_AND;
                    6'h25: id_alu_control = ALU_OR;
                    6'h2A: id_alu_control = ALU_SLT;
                    default: begin
                        id_reg_write   = 1'b0;
                        id_alu_control = ALU_ADD;
                    end
                endcase
            end
            6'h08: begin   // ADDI
                id_alu_src     = 1'b1;
                id_reg_write   = 1'b1;
                id_alu_control = ALU_ADD;
            end
            6'h0D: begin   // ORI
                id_alu_src     = 1'b1;
                id_reg_write   = 1'b1;
                id_ori         = 1'b1;
                id_alu_control = ALU_OR;
            end
            6'h0F: begin   // LUI
                id_reg_write   = 1'b1;
                id_lui         = 1'b1;
            end
            6'h23: begin   // LW
                id_alu_src     = 1'b1;
                id_mem_to_reg  = 1'b1;
                id_reg_write   = 1'b1;
                id_mem_read    = 1'b1;
                id_alu_control = ALU_ADD;
            end
            6'h2B: begin   // SW
                id_alu_src     = 1'b1;
                id_mem_write   = 1'b1;
                id_alu_control = ALU_ADD;
            end
            6'h04: begin   // BEQ
                id_branch_eq   = 1'b1;
                id_alu_control = ALU_SUB;
            end
            6'h05: begin   // BNE
                id_branch_ne   = 1'b1;
                id_alu_control = ALU_SUB;
            end
            6'h02: id_jump = 1'b1;   // J
            default: begin end
        endcase
    end

    // ---- Register file with WB-stage write ---------------------------
    reg [31:0] regs [0:31];
    integer reg_index;

    reg [31:0] mem_wb_mem_data;
    reg [31:0] mem_wb_alu_result;
    reg [4:0]  mem_wb_write_reg;
    reg        mem_wb_mem_to_reg;
    reg        mem_wb_reg_write;
    wire [31:0] wb_data = mem_wb_mem_to_reg ? mem_wb_mem_data
                                            : mem_wb_alu_result;

    wire [31:0] id_rs_value =
        (mem_wb_reg_write && (mem_wb_write_reg != 5'd0) &&
         (mem_wb_write_reg == id_rs)) ? wb_data : regs[id_rs];
    wire [31:0] id_rt_value =
        (mem_wb_reg_write && (mem_wb_write_reg != 5'd0) &&
         (mem_wb_write_reg == id_rt)) ? wb_data : regs[id_rt];

    always @(posedge clk) begin
        if (reset) begin
            for (reg_index = 0; reg_index < 32; reg_index = reg_index + 1)
                regs[reg_index] <= 32'd0;
        end else begin
            if (mem_wb_reg_write && (mem_wb_write_reg != 5'd0))
                regs[mem_wb_write_reg] <= wb_data;
            regs[0] <= 32'd0;
        end
    end

    // ---- ID / EX pipeline registers ----------------------------------
    reg [31:0] id_ex_pc4;
    reg [31:0] id_ex_rs_value;
    reg [31:0] id_ex_rt_value;
    reg [31:0] id_ex_sign_imm;
    reg [31:0] id_ex_zero_imm;
    reg [4:0]  id_ex_rs;
    reg [4:0]  id_ex_rt;
    reg [4:0]  id_ex_rd;
    reg        id_ex_reg_dst;
    reg        id_ex_alu_src;
    reg        id_ex_mem_to_reg;
    reg        id_ex_reg_write;
    reg        id_ex_mem_read;
    reg        id_ex_mem_write;
    reg        id_ex_branch_eq;
    reg        id_ex_branch_ne;
    reg        id_ex_lui;
    reg        id_ex_ori;
    reg [2:0]  id_ex_alu_control;

    // ---- EX / MEM pipeline registers ---------------------------------
    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_store_data;
    reg [4:0]  ex_mem_write_reg;
    reg        ex_mem_mem_to_reg;
    reg        ex_mem_reg_write;
    reg        ex_mem_mem_read;
    reg        ex_mem_mem_write;

    // ---- Forwarding --------------------------------------------------
    reg [31:0] ex_forward_a;
    reg [31:0] ex_forward_b;
    always @* begin
        ex_forward_a = id_ex_rs_value;
        ex_forward_b = id_ex_rt_value;

        if (ex_mem_reg_write && !ex_mem_mem_to_reg &&
            (ex_mem_write_reg != 5'd0) && (ex_mem_write_reg == id_ex_rs))
            ex_forward_a = ex_mem_alu_result;
        else if (mem_wb_reg_write && (mem_wb_write_reg != 5'd0) &&
                 (mem_wb_write_reg == id_ex_rs))
            ex_forward_a = wb_data;

        if (ex_mem_reg_write && !ex_mem_mem_to_reg &&
            (ex_mem_write_reg != 5'd0) && (ex_mem_write_reg == id_ex_rt))
            ex_forward_b = ex_mem_alu_result;
        else if (mem_wb_reg_write && (mem_wb_write_reg != 5'd0) &&
                 (mem_wb_write_reg == id_ex_rt))
            ex_forward_b = wb_data;
    end

    // ---- EX stage ALU ------------------------------------------------
    wire [31:0] ex_alu_b = id_ex_ori ? id_ex_zero_imm :
                           (id_ex_alu_src ? id_ex_sign_imm : ex_forward_b);
    reg [31:0] ex_alu_result;
    always @* begin
        if (id_ex_lui)
            ex_alu_result = {id_ex_sign_imm[15:0], 16'b0};
        else begin
            case (id_ex_alu_control)
                ALU_ADD: ex_alu_result = ex_forward_a + ex_alu_b;
                ALU_SUB: ex_alu_result = ex_forward_a - ex_alu_b;
                ALU_AND: ex_alu_result = ex_forward_a & ex_alu_b;
                ALU_OR:  ex_alu_result = ex_forward_a | ex_alu_b;
                ALU_SLT: ex_alu_result = ($signed(ex_forward_a) < $signed(ex_alu_b));
                default: ex_alu_result = 32'd0;
            endcase
        end
    end

    wire [4:0] ex_write_reg = id_ex_reg_dst ? id_ex_rd : id_ex_rt;
    wire [31:0] ex_branch_target = id_ex_pc4 + (id_ex_sign_imm << 2);
    wire ex_values_equal = (ex_forward_a == ex_forward_b);
    wire branch_taken = (id_ex_branch_eq && ex_values_equal) ||
                        (id_ex_branch_ne && !ex_values_equal);

    wire load_use_stall = id_ex_mem_read && (id_ex_rt != 5'd0) &&
                          ((id_ex_rt == id_rs) || (id_ex_rt == id_rt));

    // ---- Memory-mapped I/O (MEM stage) -------------------------------
    reg [31:0] mem_read_data;
    always @* begin
        mem_read_data = 32'd0;
        if (ex_mem_mem_read) begin
            case (ex_mem_alu_result)
                STRIPE1_ADDR: mem_read_data = {8'd0, colour_top};
                STRIPE2_ADDR: mem_read_data = {8'd0, colour_middle};
                STRIPE3_ADDR: mem_read_data = {8'd0, colour_bottom};
                AUDIO_ADDR:   mem_read_data = {31'd0, audio_enable};
                default:      mem_read_data = 32'd0;
            endcase
        end
    end

    // ---- I/O register writes -----------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            colour_top    <= 24'hFF0000;   // Red
            colour_middle <= 24'h0000FF;   // Green
            colour_bottom <= 24'h00FF00;   // Blue
            audio_enable  <= 1'b0;
        end else if (ex_mem_mem_write) begin
            case (ex_mem_alu_result)
                STRIPE1_ADDR: colour_top    <= ex_mem_store_data[23:0];
                STRIPE2_ADDR: colour_middle <= ex_mem_store_data[23:0];
                STRIPE3_ADDR: colour_bottom <= ex_mem_store_data[23:0];
                AUDIO_ADDR:   audio_enable  <= ex_mem_store_data[0];
                default:      ;
            endcase
        end
    end

    // ---- Pipeline register update ------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            pc                 <= 32'd0;
            if_id_instr        <= 32'd0;
            if_id_pc4          <= 32'd0;
            id_ex_pc4          <= 32'd0;
            id_ex_rs_value     <= 32'd0;
            id_ex_rt_value     <= 32'd0;
            id_ex_sign_imm     <= 32'd0;
            id_ex_zero_imm     <= 32'd0;
            id_ex_rs           <= 5'd0;
            id_ex_rt           <= 5'd0;
            id_ex_rd           <= 5'd0;
            id_ex_reg_dst      <= 1'b0;
            id_ex_alu_src      <= 1'b0;
            id_ex_mem_to_reg   <= 1'b0;
            id_ex_reg_write    <= 1'b0;
            id_ex_mem_read     <= 1'b0;
            id_ex_mem_write    <= 1'b0;
            id_ex_branch_eq    <= 1'b0;
            id_ex_branch_ne    <= 1'b0;
            id_ex_lui          <= 1'b0;
            id_ex_ori          <= 1'b0;
            id_ex_alu_control  <= ALU_ADD;
            ex_mem_alu_result  <= 32'd0;
            ex_mem_store_data  <= 32'd0;
            ex_mem_write_reg   <= 5'd0;
            ex_mem_mem_to_reg  <= 1'b0;
            ex_mem_reg_write   <= 1'b0;
            ex_mem_mem_read    <= 1'b0;
            ex_mem_mem_write   <= 1'b0;
            mem_wb_mem_data    <= 32'd0;
            mem_wb_alu_result  <= 32'd0;
            mem_wb_write_reg   <= 5'd0;
            mem_wb_mem_to_reg  <= 1'b0;
            mem_wb_reg_write   <= 1'b0;
        end else begin
            // MEM → WB
            mem_wb_mem_data   <= mem_read_data;
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_write_reg  <= ex_mem_write_reg;
            mem_wb_mem_to_reg <= ex_mem_mem_to_reg;
            mem_wb_reg_write  <= ex_mem_reg_write;

            // EX → MEM
            ex_mem_alu_result <= ex_alu_result;
            ex_mem_store_data <= ex_forward_b;
            ex_mem_write_reg  <= ex_write_reg;
            ex_mem_mem_to_reg <= id_ex_mem_to_reg;
            ex_mem_reg_write  <= id_ex_reg_write;
            ex_mem_mem_read   <= id_ex_mem_read;
            ex_mem_mem_write  <= id_ex_mem_write;

            // IF → ID, PC update
            if (branch_taken) begin
                pc          <= ex_branch_target;
                if_id_instr <= 32'd0;
                if_id_pc4   <= 32'd0;
            end else if (load_use_stall) begin
                pc          <= pc;
                if_id_instr <= if_id_instr;
                if_id_pc4   <= if_id_pc4;
            end else if (id_jump) begin
                pc          <= id_jump_target;
                if_id_instr <= 32'd0;
                if_id_pc4   <= 32'd0;
            end else begin
                pc          <= pc + 32'd4;
                if_id_instr <= fetched_instr;
                if_id_pc4   <= pc + 32'd4;
            end

            // ID → EX
            if (branch_taken || load_use_stall || id_jump) begin
                id_ex_pc4         <= 32'd0;
                id_ex_rs_value    <= 32'd0;
                id_ex_rt_value    <= 32'd0;
                id_ex_sign_imm    <= 32'd0;
                id_ex_zero_imm    <= 32'd0;
                id_ex_rs          <= 5'd0;
                id_ex_rt          <= 5'd0;
                id_ex_rd          <= 5'd0;
                id_ex_reg_dst     <= 1'b0;
                id_ex_alu_src     <= 1'b0;
                id_ex_mem_to_reg  <= 1'b0;
                id_ex_reg_write   <= 1'b0;
                id_ex_mem_read    <= 1'b0;
                id_ex_mem_write   <= 1'b0;
                id_ex_branch_eq   <= 1'b0;
                id_ex_branch_ne   <= 1'b0;
                id_ex_lui         <= 1'b0;
                id_ex_ori         <= 1'b0;
                id_ex_alu_control <= ALU_ADD;
            end else begin
                id_ex_pc4         <= if_id_pc4;
                id_ex_rs_value    <= id_rs_value;
                id_ex_rt_value    <= id_rt_value;
                id_ex_sign_imm    <= id_sign_imm;
                id_ex_zero_imm    <= id_zero_imm;
                id_ex_rs          <= id_rs;
                id_ex_rt          <= id_rt;
                id_ex_rd          <= id_rd;
                id_ex_reg_dst     <= id_reg_dst;
                id_ex_alu_src     <= id_alu_src;
                id_ex_mem_to_reg  <= id_mem_to_reg;
                id_ex_reg_write   <= id_reg_write;
                id_ex_mem_read    <= id_mem_read;
                id_ex_mem_write   <= id_mem_write;
                id_ex_branch_eq   <= id_branch_eq;
                id_ex_branch_ne   <= id_branch_ne;
                id_ex_lui         <= id_lui;
                id_ex_ori         <= id_ori;
                id_ex_alu_control <= id_alu_control;
            end
        end
    end
endmodule
