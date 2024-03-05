using Godot;
using System.Collections.Generic;

public partial class EarthScene : ElementScene<EarthBodyType>
{
    private static Dictionary<EarthBodyType, PackedScene> _earthbodyscenes 
        = new()
    {
        {EarthBodyType.Brick, (PackedScene)ResourceLoader.Load("res://scenes/earthbrick.tscn")},
        {EarthBodyType.Soil,  (PackedScene)ResourceLoader.Load("res://scenes/earthsoil.tscn")},
    };

    public EarthScene(): base(_earthbodyscenes) {}
}
