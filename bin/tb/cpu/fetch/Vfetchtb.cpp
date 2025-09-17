// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vfetchtb__pch.h"

//============================================================
// Constructors

Vfetchtb::Vfetchtb(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vfetchtb__Syms(contextp(), _vcname__, this)}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vfetchtb::Vfetchtb(const char* _vcname__)
    : Vfetchtb(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vfetchtb::~Vfetchtb() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vfetchtb___024root___eval_debug_assertions(Vfetchtb___024root* vlSelf);
#endif  // VL_DEBUG
void Vfetchtb___024root___eval_static(Vfetchtb___024root* vlSelf);
void Vfetchtb___024root___eval_initial(Vfetchtb___024root* vlSelf);
void Vfetchtb___024root___eval_settle(Vfetchtb___024root* vlSelf);
void Vfetchtb___024root___eval(Vfetchtb___024root* vlSelf);

void Vfetchtb::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vfetchtb::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vfetchtb___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vfetchtb___024root___eval_static(&(vlSymsp->TOP));
        Vfetchtb___024root___eval_initial(&(vlSymsp->TOP));
        Vfetchtb___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vfetchtb___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vfetchtb::eventsPending() { return !vlSymsp->TOP.__VdlySched.empty(); }

uint64_t Vfetchtb::nextTimeSlot() { return vlSymsp->TOP.__VdlySched.nextTimeSlot(); }

//============================================================
// Utilities

const char* Vfetchtb::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vfetchtb___024root___eval_final(Vfetchtb___024root* vlSelf);

VL_ATTR_COLD void Vfetchtb::final() {
    Vfetchtb___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vfetchtb::hierName() const { return vlSymsp->name(); }
const char* Vfetchtb::modelName() const { return "Vfetchtb"; }
unsigned Vfetchtb::threads() const { return 1; }
void Vfetchtb::prepareClone() const { contextp()->prepareClone(); }
void Vfetchtb::atClone() const {
    contextp()->threadPoolpOnClone();
}
