// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfetchtb.h for the primary calling header

#include "Vfetchtb__pch.h"
#include "Vfetchtb___024root.h"

VL_ATTR_COLD void Vfetchtb___024root___eval_initial__TOP(Vfetchtb___024root* vlSelf);
VlCoroutine Vfetchtb___024root___eval_initial__TOP__Vtiming__0(Vfetchtb___024root* vlSelf);

void Vfetchtb___024root___eval_initial(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval_initial\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vfetchtb___024root___eval_initial__TOP(vlSelf);
    Vfetchtb___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    vlSelfRef.__Vtrigprevexpr___TOP__fetchtb__DOT__clk__0 
        = vlSelfRef.fetchtb__DOT__clk;
}

VL_INLINE_OPT VlCoroutine Vfetchtb___024root___eval_initial__TOP__Vtiming__0(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (1U) {
        co_await vlSelfRef.__VdlySched.delay(0xaULL, 
                                             nullptr, 
                                             "tb/cpu/fetch/fetchtb.sv", 
                                             52);
        vlSelfRef.fetchtb__DOT__clk = (1U & (~ (IData)(vlSelfRef.fetchtb__DOT__clk)));
    }
}

void Vfetchtb___024root___eval_act(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval_act\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vfetchtb___024root___nba_sequent__TOP__0(Vfetchtb___024root* vlSelf);

void Vfetchtb___024root___eval_nba(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval_nba\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vfetchtb___024root___nba_sequent__TOP__0(vlSelf);
    }
}

VL_INLINE_OPT void Vfetchtb___024root___nba_sequent__TOP__0(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___nba_sequent__TOP__0\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY((VL_GTES_III(32, 0U, VL_FREAD_I(32
                                                    ,0
                                                    ,0
                                                    , &(vlSelfRef.fetchtb__DOT__unnamedblk2__DOT__res_data)
                                                    , vlSelfRef.fetchtb__DOT__fres
                                                    , 0
                                                    , 0))))) {
        if (VL_UNLIKELY((VL_FERROR_IN(vlSelfRef.fetchtb__DOT__fres
                                      , vlSelfRef.fetchtb__DOT__errmsg)))) {
            VL_WRITEF_NX("ERROR: failed read with error %@\n",0,
                         -1,&(vlSelfRef.fetchtb__DOT__errmsg));
        }
        VL_FINISH_MT("tb/cpu/fetch/fetchtb.sv", 127, "");
    }
    if (VL_UNLIKELY(((0U != vlSelfRef.fetchtb__DOT__unnamedblk2__DOT__res_data)))) {
        VL_WRITEF_NX("FAIL: 00000000 != %x\n",0,32,
                     vlSelfRef.fetchtb__DOT__unnamedblk2__DOT__res_data);
    }
}

void Vfetchtb___024root___timing_resume(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___timing_resume\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((2ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vfetchtb___024root___eval_triggers__act(Vfetchtb___024root* vlSelf);

bool Vfetchtb___024root___eval_phase__act(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval_phase__act\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<2> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vfetchtb___024root___eval_triggers__act(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        Vfetchtb___024root___timing_resume(vlSelf);
        Vfetchtb___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vfetchtb___024root___eval_phase__nba(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval_phase__nba\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vfetchtb___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfetchtb___024root___dump_triggers__nba(Vfetchtb___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vfetchtb___024root___dump_triggers__act(Vfetchtb___024root* vlSelf);
#endif  // VL_DEBUG

void Vfetchtb___024root___eval(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY(((0x64U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vfetchtb___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("tb/cpu/fetch/fetchtb.sv", 7, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY(((0x64U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vfetchtb___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("tb/cpu/fetch/fetchtb.sv", 7, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (Vfetchtb___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (Vfetchtb___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vfetchtb___024root___eval_debug_assertions(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval_debug_assertions\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
