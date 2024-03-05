using System;

[Flags]
public enum Directions
{
    Right = 1 << 0,
    Down = 1 << 1,
    Left = 1 << 2,
    Up = 1 << 3,
}