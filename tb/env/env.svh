
class cpu_env extends uvm_env;
  `ucm_component_utils(cpu_env)

  function new(string name, uvm_component parent);
    super.new(name, parent)
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #10
    phase.drop_objection(this);
  endtask: run_phase
endclass: cpu_env
