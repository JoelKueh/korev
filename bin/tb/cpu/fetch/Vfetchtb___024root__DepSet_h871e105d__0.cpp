// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfetchtb.h for the primary calling header

#include "Vfetchtb__pch.h"
#include "Vfetchtb__Syms.h"
#include "Vfetchtb___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfetchtb___024root___dump_triggers__act(Vfetchtb___024root* vlSelf);
#endif  // VL_DEBUG

void Vfetchtb___024root___eval_triggers__act(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval_triggers__act\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered.set(0U, ((IData)(vlSelfRef.fetchtb__DOT__clk) 
                                       & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__fetchtb__DOT__clk__0))));
    vlSelfRef.__VactTriggered.set(1U, vlSelfRef.__VdlySched.awaitingCurrentTime());
    vlSelfRef.__Vtrigprevexpr___TOP__fetchtb__DOT__clk__0 
        = vlSelfRef.fetchtb__DOT__clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfetchtb___024root___dump_triggers__act(vlSelf);
    }
#endif
}
