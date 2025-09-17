// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vfetchtb.h for the primary calling header

#ifndef VERILATED_VFETCHTB___024ROOT_H_
#define VERILATED_VFETCHTB___024ROOT_H_  // guard

#include "verilated.h"


class Vfetchtb__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vfetchtb___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ fetchtb__DOT__clk;
    CData/*7:0*/ fetchtb__DOT__unnamedblk1__DOT__imem_data;
    CData/*7:0*/ fetchtb__DOT____Vlvbound_h3e0ded4c__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__fetchtb__DOT__clk__0;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ fetchtb__DOT__fres;
    IData/*31:0*/ fetchtb__DOT__unnamedblk2__DOT__res_data;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<CData/*7:0*/, 8196> fetchtb__DOT__i_mmu__DOT__icache_l1;
    std::string fetchtb__DOT__errmsg;
    std::string fetchtb__DOT__imem_fname;
    std::string fetchtb__DOT__res_fname;
    VlTriggerVec<1> __VactTriggered;
    VlTriggerVec<1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vfetchtb__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vfetchtb___024root(Vfetchtb__Syms* symsp, const char* v__name);
    ~Vfetchtb___024root();
    VL_UNCOPYABLE(Vfetchtb___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
