using Godot;
using System.Collections.Generic;

public partial class BlockScener: Node, IEnumerable<BlockMarker>
{
    public IReadOnlyDictionary<BlockMarker, Node2D> Blocks => _blocks;
    private Dictionary<BlockMarker, Node2D> _blocks = new();

    public void Add(BlockMarker marker)
    {
        if (!_blocks.ContainsKey(marker))
        {
            Node2D node = (Node2D)marker.Prototype.Instantiate();
            node.Position = marker.Position;
            node.RotationDegrees = marker.RotationDegrees;
            _blocks.Add(marker, node);
            this.AddChild(node);
        }
        return ;
    }
    public void Remove(BlockMarker marker)
    {
        if (_blocks.ContainsKey(marker))
        {
            this.RemoveChild(_blocks[marker]);
            _blocks[marker].QueueFree();
            _blocks.Remove(marker);
        }
        return ;
    }
    
    public IEnumerator<BlockMarker> GetEnumerator()
        => Blocks.Keys.GetEnumerator();
    System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        => Blocks.Keys.GetEnumerator();
}