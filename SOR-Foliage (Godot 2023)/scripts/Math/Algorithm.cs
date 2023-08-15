using System;

namespace Foliage.Math;

public static class Algorithm
{
    /// <summary>
    /// source: https://learn.microsoft.com/dotnet/api/system.object.gethashcode
    /// </summary>
    public static int ShiftAndWrap(int val, int positions)
    {
        positions = positions & 0x1F;
        uint number = BitConverter.ToUInt32(BitConverter.GetBytes(val), 0);
        uint wrapped = number >> (32 - positions);
        return BitConverter.ToInt32(BitConverter.GetBytes((number << positions) | wrapped), 0);
    }
}
