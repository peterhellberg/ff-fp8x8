// Code generated by bitsy-to-w4-sprites; DO NOT EDIT.

// Radial - 8x8.me fill patterns (bitsy)
// This work is dedicated to the Public Domain by ACED, licensed under CC0
// https://creativecommons.org/publicdomain/zero/1.0/

pub const Radial = enum {
    nebula,
    pinwheel,
    pivot,
    fylfot,
    rotary,
    nova,
    swirl,
    swarm,
    encircled,
    spokes,
    cartwheel,
    cartwheelbold,
    cartwheelextrabold,

    pub fn sprite(self: Radial) [8]u8 {
       return switch (self) {
            .nebula => [8]u8{
                0b00000000,
                0b00010000,
                0b00001000,
                0b00111010,
                0b01011100,
                0b00010000,
                0b00001000,
                0b00000000,
            },
            .pinwheel => [8]u8{
                0b00000000,
                0b00001000,
                0b00001000,
                0b01111000,
                0b00011110,
                0b00010000,
                0b00010000,
                0b00000000,
            },
            .pivot => [8]u8{
                0b00001000,
                0b00001000,
                0b00011000,
                0b11100100,
                0b00100111,
                0b00011000,
                0b00010000,
                0b00010000,
            },
            .fylfot => [8]u8{
                0b00110000,
                0b00010000,
                0b00011001,
                0b00100111,
                0b11100100,
                0b10011000,
                0b00001000,
                0b00001100,
            },
            .rotary => [8]u8{
                0b00001000,
                0b00001000,
                0b00110100,
                0b11000100,
                0b00100011,
                0b00101100,
                0b00010000,
                0b00010000,
            },
            .nova => [8]u8{
                0b00000100,
                0b00001100,
                0b11110100,
                0b01000100,
                0b00100010,
                0b00101111,
                0b00110000,
                0b00100000,
            },
            .swirl => [8]u8{
                0b00001000,
                0b00000100,
                0b01100100,
                0b10000000,
                0b00000001,
                0b00100110,
                0b00100000,
                0b00010000,
            },
            .swarm => [8]u8{
                0b00000100,
                0b00001000,
                0b10100100,
                0b01000000,
                0b00000010,
                0b00100101,
                0b00010000,
                0b00100000,
            },
            .encircled => [8]u8{
                0b00000100,
                0b01000010,
                0b10000000,
                0b00011000,
                0b00011000,
                0b00000001,
                0b01000010,
                0b00100000,
            },
            .spokes => [8]u8{
                0b00001000,
                0b00001100,
                0b01100100,
                0b11011000,
                0b00011011,
                0b00100110,
                0b00110000,
                0b00010000,
            },
            .cartwheel => [8]u8{
                0b00001000,
                0b00101100,
                0b01100110,
                0b11011000,
                0b00011011,
                0b01100110,
                0b00110100,
                0b00010000,
            },
            .cartwheelbold => [8]u8{
                0b00101100,
                0b01101110,
                0b11100111,
                0b11011000,
                0b00011011,
                0b11100111,
                0b01110110,
                0b00110100,
            },
            .cartwheelextrabold => [8]u8{
                0b01101110,
                0b11101111,
                0b11100111,
                0b11011000,
                0b00011011,
                0b11100111,
                0b11110111,
                0b01110110,
            },
        };
    }
};
