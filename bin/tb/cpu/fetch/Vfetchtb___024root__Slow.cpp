// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfetchtb.h for the primary calling header

#include "Vfetchtb__pch.h"
#include "Vfetchtb__Syms.h"
#include "Vfetchtb___024root.h"

void Vfetchtb___024root___ctor_var_reset(Vfetchtb___024root* vlSelf);

Vfetchtb___024root::Vfetchtb___024root(Vfetchtb__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , __VdlySched{*symsp->_vm_contextp__}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vfetchtb___024root___ctor_var_reset(this);
}

void Vfetchtb___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vfetchtb___024root::~Vfetchtb___024root() {
}
