using Vector2 = System.Numerics.Vector2;
using System.Linq;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Collections.Specialized;

namespace Foliage.Board.Base;

public class BoardData
{
    /// <summary>
    /// Collects all the structures on this board.
    /// </summary>
    public IList<IStructural> Structures => _structures;
    /// <summary>
    /// Inspects a tile to know about all structures on it.
    /// </summary>
    /// <param name="position">The position of the tile inspected.</param>
    /// <returns>All structures on the tile inspected.</returns>
    public List<IStructural> Inspect(Vector2 position)
        => _tiles.ContainsKey(position)? _tiles[position].ToList(): new();
    
    public BoardData()
    {
        (_structures, _tiles, _updates) = (new(), new(), new());
        _structures.CollectionChanged += StructuresChanged;
    }

    private ObservableCollection<IStructural> _structures { get; }
    private Dictionary<Vector2, List<IStructural>> _tiles { get; }
    private Dictionary<IStructural, NotifyCollectionChangedEventHandler> _updates { get; }
    
    private void StructuresChanged(object sender, 
                                   NotifyCollectionChangedEventArgs e)
    {
        if (e.Action == NotifyCollectionChangedAction.Move) return;
        if (e.Action == NotifyCollectionChangedAction.Reset)
        {
            _tiles.Clear();
            return;
        }
        foreach(IStructural structure in e.OldItems)
        {
            foreach(KeyValuePair<Vector2, IFunctional> tile 
                    in structure.OwningBody.Bodies)
            {
                Vector2 position = tile.Key;
                structure.OwningBody.BodiesChanged -= _updates[structure];
                _updates.Remove(structure);
                _tiles[position].Remove(structure);
                if (_tiles[position].Count == 0) _tiles.Remove(position);
            }
        }
        foreach(IStructural structure in e.NewItems)
        {
            foreach(KeyValuePair<Vector2, IFunctional> tile
                    in structure.OwningBody.Bodies)
            {
                Vector2 position = tile.Key;
                if (_tiles.ContainsKey(position)) _tiles[position] = new();
                _tiles[position].Add(structure);
                _updates[structure] = (sender, e) => Update(structure, sender, e);
                structure.OwningBody.BodiesChanged += _updates[structure];
            }
        }
    }

    private void Update(IStructural structure, 
                        object sender, 
                        NotifyCollectionChangedEventArgs e)
    {
        if (e.Action == NotifyCollectionChangedAction.Move) return;
        if (e.Action == NotifyCollectionChangedAction.Reset)
        {
            foreach(KeyValuePair<Vector2, List<IStructural>> tile 
                    in _tiles) tile.Value.Remove(structure);
            return;
        }
        foreach(KeyValuePair<Vector2, IFunctional> body in e.OldItems)
        {
            Vector2 position = body.Key;
            _tiles[position].Remove(structure);
            if (_tiles[position].Count == 0) _tiles.Remove(position);
        }
        foreach(KeyValuePair<Vector2, IFunctional> body in e.NewItems)
        {
            Vector2 position = body.Key;
            if (_tiles.ContainsKey(position)) _tiles[position] = new();
            _tiles[position].Add(structure);
        }
    }
}
