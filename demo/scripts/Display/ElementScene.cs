using Godot;
using System.Collections.Generic;

public partial class ElementScene<TBodyType>: 
                    Node2D, IEnumerable<ElementBodyArguments<TBodyType>>
{
    public IReadOnlyDictionary<ElementBodyArguments<TBodyType>, Node2D> 
            Bodies => _bodies;

    private Dictionary<ElementBodyArguments<TBodyType>, Node2D> _bodies;
    
    private IDictionary<TBodyType, PackedScene> _bodyscenes;

    public ElementScene(IDictionary<TBodyType, PackedScene> bodyscenes)
    {
        _bodyscenes = bodyscenes;
        _bodies = new();
    }

    public const int PositionScale = 32;
    public const float RotationScale = System.MathF.PI / 180;

    public void Add(TBodyType bodyType, 
                    float reducedPositionX, 
                    float reducedPositionY, 
                    float reducedRotation = 0)
    {
        Node2D node = (Node2D)_bodyscenes[bodyType].Instantiate();
        node.Position = new Vector2(reducedPositionX * PositionScale,
                                    reducedPositionY * PositionScale);
        node.Rotation = reducedRotation * RotationScale;
        this.AddChild(node);
        _bodies.Add(new(bodyType, 
                        reducedPositionX, 
                        reducedPositionY, 
                        reducedRotation), 
                    node);
        return ;
    }

    public void Remove(TBodyType bodyType, 
                       float reducedPositionX, 
                       float reducedPositionY,
                       float reducedRotation = 0)
    {
        ElementBodyArguments<TBodyType> arg 
                 = new(bodyType, 
                       reducedPositionX, 
                       reducedPositionY, 
                       reducedRotation);
        if (_bodies.ContainsKey(arg))
        {
            _bodies[arg].Free();
            _bodies.Remove(arg);
        }
        return ;
    }

    public IEnumerator<ElementBodyArguments<TBodyType>> GetEnumerator()
        => _bodies.Keys.GetEnumerator();
    System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        => _bodies.Keys.GetEnumerator();
}