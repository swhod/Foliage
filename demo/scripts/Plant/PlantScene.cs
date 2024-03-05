using Godot;
using System.Collections.Generic;

public partial class PlantScene: ElementScene<PlantBodyType>
{
    private static Dictionary<PlantBodyType, PackedScene> _plantbodyscenes 
        = new()
    {
        {PlantBodyType.Root, (PackedScene)ResourceLoader.Load("res://scenes/plantroot.tscn")},
        {PlantBodyType.Stem, (PackedScene)ResourceLoader.Load("res://scenes/plantstem.tscn")},
        {PlantBodyType.Leaf, (PackedScene)ResourceLoader.Load("res://scenes/plantleaf.tscn")},
    };

    public PlantScene(): base(_plantbodyscenes) {}
}
