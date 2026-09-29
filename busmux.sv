module busmux(
    input GateMARMUX,
    input GatePC,
    input GateALU,
    input GateMDR,

    output [15:0] busmux_LOGIC,
    output [15:0] busmux_IR,
    output busmux_MAR,
    output busmux_MIO_EN,
    output busmux_REG_FILE,
    output busmux_PCMUX;
);
endmodule