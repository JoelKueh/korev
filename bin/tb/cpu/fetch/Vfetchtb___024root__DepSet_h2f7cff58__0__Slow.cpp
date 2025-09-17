// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfetchtb.h for the primary calling header

#include "Vfetchtb__pch.h"
#include "Vfetchtb___024root.h"

VL_ATTR_COLD void Vfetchtb___024root___eval_static__TOP(Vfetchtb___024root* vlSelf);

VL_ATTR_COLD void Vfetchtb___024root___eval_static(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval_static\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vfetchtb___024root___eval_static__TOP(vlSelf);
}

VL_ATTR_COLD void Vfetchtb___024root___eval_static__TOP(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval_static__TOP\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.fetchtb__DOT__clk = 0U;
}

VL_ATTR_COLD void Vfetchtb___024root___eval_initial__TOP(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval_initial__TOP\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ fetchtb__DOT____Vincrement1;
    fetchtb__DOT____Vincrement1 = 0;
    IData/*31:0*/ fetchtb__DOT__fimem;
    fetchtb__DOT__fimem = 0;
    IData/*31:0*/ fetchtb__DOT__unnamedblk1__DOT__i;
    fetchtb__DOT__unnamedblk1__DOT__i = 0;
    VlWide<3>/*95:0*/ __Vtemp_1;
    VlWide<3>/*95:0*/ __Vtemp_2;
    // Body
    __Vtemp_1[0U] = 0x453d2573U;
    __Vtemp_1[1U] = 0x5f46494cU;
    __Vtemp_1[2U] = 0x494d454dU;
    if (VL_UNLIKELY(((! VL_VALUEPLUSARGS_INN(64, VL_CVT_PACK_STR_NW(3, __Vtemp_1), 
                                             vlSelfRef.fetchtb__DOT__imem_fname))))) {
        VL_WRITEF_NX("ERROR: IMEM_FILE must be specified in plusargs.\n",0);
        VL_FINISH_MT("tb/cpu/fetch/fetchtb.sv", 71, "");
    }
    __Vtemp_2[0U] = 0x453d2573U;
    __Vtemp_2[1U] = 0x5f46494cU;
    __Vtemp_2[2U] = 0x524553U;
    if (VL_UNLIKELY(((! VL_VALUEPLUSARGS_INN(64, VL_CVT_PACK_STR_NW(3, __Vtemp_2), 
                                             vlSelfRef.fetchtb__DOT__res_fname))))) {
        VL_WRITEF_NX("ERROR: RES_FILE must be specified in plusargs.\n",0);
        VL_FINISH_MT("tb/cpu/fetch/fetchtb.sv", 76, "");
    }
    fetchtb__DOT__fimem = VL_FOPEN_NN(VL_CVT_PACK_STR_NN(vlSelfRef.fetchtb__DOT__imem_fname)
                                      , std::string{"r"});
    ;
    if (VL_UNLIKELY(((0U == fetchtb__DOT__fimem)))) {
        VL_WRITEF_NX("ERROR: could not open %@\n",0,
                     -1,&(vlSelfRef.fetchtb__DOT__imem_fname));
        VL_FINISH_MT("tb/cpu/fetch/fetchtb.sv", 83, "");
    }
    vlSelfRef.fetchtb__DOT__fres = VL_FOPEN_NN(VL_CVT_PACK_STR_NN(vlSelfRef.fetchtb__DOT__res_fname)
                                               , std::string{"r"});
    ;
    if (VL_UNLIKELY(((0U == vlSelfRef.fetchtb__DOT__fres)))) {
        VL_WRITEF_NX("ERROR: could not open %@\n",0,
                     -1,&(vlSelfRef.fetchtb__DOT__res_fname));
        VL_FINISH_MT("tb/cpu/fetch/fetchtb.sv", 89, "");
    }
    fetchtb__DOT__unnamedblk1__DOT__i = 0U;
    while (VL_LTS_III(32, 0U, VL_FREAD_I(8,0,0, &(vlSelfRef.fetchtb__DOT__unnamedblk1__DOT__imem_data)
                                         , fetchtb__DOT__fimem
                                         , 0, 0))) {
        fetchtb__DOT____Vincrement1 = fetchtb__DOT__unnamedblk1__DOT__i;
        fetchtb__DOT__unnamedblk1__DOT__i = ((IData)(1U) 
                                             + fetchtb__DOT__unnamedblk1__DOT__i);
        vlSelfRef.fetchtb__DOT____Vlvbound_h3e0ded4c__0 
            = vlSelfRef.fetchtb__DOT__unnamedblk1__DOT__imem_data;
        if (VL_LIKELY(((0x2003U >= (0x3fffU & fetchtb__DOT____Vincrement1))))) {
            vlSelfRef.fetchtb__DOT__i_mmu__DOT__icache_l1[(0x3fffU 
                                                           & fetchtb__DOT____Vincrement1)] 
                = vlSelfRef.fetchtb__DOT____Vlvbound_h3e0ded4c__0;
        }
    }
    if (VL_UNLIKELY((VL_FERROR_IN(fetchtb__DOT__fimem
                                  , vlSelfRef.fetchtb__DOT__errmsg)))) {
        VL_WRITEF_NX("ERROR: failed read with error %@\n",0,
                     -1,&(vlSelfRef.fetchtb__DOT__errmsg));
        VL_FINISH_MT("tb/cpu/fetch/fetchtb.sv", 102, "");
    }
}

VL_ATTR_COLD void Vfetchtb___024root___eval_final(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval_final\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vfetchtb___024root___eval_settle(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___eval_settle\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfetchtb___024root___dump_triggers__act(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___dump_triggers__act\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VactTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge fetchtb.clk)\n");
    }
    if ((2ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfetchtb___024root___dump_triggers__nba(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___dump_triggers__nba\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VnbaTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge fetchtb.clk)\n");
    }
    if ((2ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vfetchtb___024root___ctor_var_reset(Vfetchtb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfetchtb___024root___ctor_var_reset\n"); );
    Vfetchtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelf->fetchtb__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->fetchtb__DOT__fres = 0;
    vlSelf->fetchtb__DOT__unnamedblk1__DOT__imem_data = VL_RAND_RESET_I(8);
    vlSelf->fetchtb__DOT__unnamedblk2__DOT__res_data = VL_RAND_RESET_I(32);
    vlSelf->fetchtb__DOT____Vlvbound_h3e0ded4c__0 = VL_RAND_RESET_I(8);
    for (int __Vi0 = 0; __Vi0 < 8196; ++__Vi0) {
        vlSelf->fetchtb__DOT__i_mmu__DOT__icache_l1[__Vi0] = VL_RAND_RESET_I(8);
    }
    vlSelf->__Vtrigprevexpr___TOP__fetchtb__DOT__clk__0 = VL_RAND_RESET_I(1);
}
