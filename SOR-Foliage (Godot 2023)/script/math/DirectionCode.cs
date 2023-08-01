/// <summary>
/// 蕴含方向信息的 <see langword="byte"/> 型编码
/// </summary>
public class DirectionCode
{
    private byte _code = 0;
    public byte Code { get => _code; set => _code = (byte)(value & 0b_1111); }
    public bool Right { get => (_code & 1) == 1; }
    public bool Up { get => ((_code >> 1) & 1) == 1; }
    public bool Left { get => ((_code >> 2) & 1) == 1; }
    public bool Down { get => (_code >> 3) == 1; }

    public DirectionCode(byte code) => Code = code;

    public DirectionCode(bool right, bool up, bool left, bool down) 
        => Code = (byte)((right? 1: 0) + (up? 2: 0) + (left? 4: 0) + (down? 8: 0));
    
    public static DirectionCode operator &(DirectionCode d1, DirectionCode d2)
        => new DirectionCode((byte)(d1._code & d2._code));
    
    public static DirectionCode operator |(DirectionCode d1, DirectionCode d2)
        => new DirectionCode((byte)(d1._code | d2._code));
    
    public static DirectionCode operator ^(DirectionCode d1, DirectionCode d2)
        => new DirectionCode((byte)(d1._code ^ d2._code));
}
