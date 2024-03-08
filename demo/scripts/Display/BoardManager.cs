using Godot;
using System.Collections.Generic;

public partial class BoardManager: Node, IEnumerable<IBlockable>
{
    [Export]
    public bool EnableInitialization = false;
    [Export]
    public BoardData InitialBoard { get; set; }

    public override void _Ready()
    {
        base._Ready();
        this.Clear();
        if (EnableInitialization) this.Load(InitialBoard);
    }

    public void Load(BoardData board)
    {
        foreach(IBlockable blockable in board)
            this.Add(blockable);
    }
    public void Clear()
    {
        foreach(IBlockable blockable in _parts.Keys)
            this.Remove(blockable);
    }

    public IReadOnlyDictionary<IBlockable, BlockScener> Parts => _parts;
    private Dictionary<IBlockable, BlockScener> _parts = new();

    public void Add(IBlockable blockable)
    {
        if (!_parts.ContainsKey(blockable))
        {
            BlockScener scener = new();
            foreach(BlockMarker marker in blockable.BlockMarkers)
                scener.Add(marker);
            _parts.Add(blockable, scener);
            this.AddChild(scener);
            blockable.BlockMarkerAdded += AddMarker;
            blockable.BlockMarkerRemoved += RemoveMarker;
        }
        return ;
    }
    public void Remove(IBlockable blockable)
    {
        if (_parts.ContainsKey(blockable))
        {
            blockable.BlockMarkerAdded -= AddMarker;
            blockable.BlockMarkerRemoved -= RemoveMarker;
            this.RemoveChild(_parts[blockable]);
            _parts[blockable].QueueFree();
            _parts.Remove(blockable);
        }
        return ;
    }

    private void AddMarker(object sender, BlockMarker marker)
        => _parts[(IBlockable)sender].Add(marker);
    private void RemoveMarker(object sender, BlockMarker marker)
        => _parts[(IBlockable)sender].Remove(marker);

    public IEnumerator<IBlockable> GetEnumerator()
        => Parts.Keys.GetEnumerator();
    System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        => Parts.Keys.GetEnumerator();
}