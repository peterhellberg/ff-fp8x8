// Code generated by bitsy-to-w4-sprites; DO NOT EDIT.

// Other - 8x8.me fill patterns (bitsy)
// This work is dedicated to the Public Domain by ACED, licensed under CC0
// https://creativecommons.org/publicdomain/zero/1.0/

pub const Other = enum {
    chain,
    chainlarge,
    rosette,
    snowflake,
    festive,
    yuletide,

    pub fn sprite(self: Other) [8]u8 {
       return switch (self) {
            .chain => [8]u8{
                0b00010000,
                0b00101000,
                0b00101000,
                0b00010000,
                0b00010000,
                0b00101000,
                0b00101000,
                0b00010000,
            },
            .chainlarge => [8]u8{
                0b00010000,
                0b00111000,
                0b01010100,
                0b01000100,
                0b01000100,
                0b01010100,
                0b00111000,
                0b00010000,
            },
            .rosette => [8]u8{
                0b11011100,
                0b00011000,
                0b10000001,
                0b10110011,
                0b00111011,
                0b00011000,
                0b10000001,
                0b11001101,
            },
            .snowflake => [8]u8{
                0b00010000,
                0b11010110,
                0b01101100,
                0b00010000,
                0b01101100,
                0b11010110,
                0b00010000,
                0b00000000,
            },
            .festive => [8]u8{
                0b00001000,
                0b01000001,
                0b00110110,
                0b00010100,
                0b10001000,
                0b00010100,
                0b00110110,
                0b01000001,
            },
            .yuletide => [8]u8{
                0b10001000,
                0b01000001,
                0b00100010,
                0b00010100,
                0b10001000,
                0b00000000,
                0b10101010,
                0b00000000,
            },
        };
    }
};
