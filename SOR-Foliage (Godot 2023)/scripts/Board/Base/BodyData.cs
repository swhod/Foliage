using Vector2 = System.Numerics.Vector2;
using Foliage.Math;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Collections.Specialized;

namespace Foliage.Board.Base;

public class BodyData
{
    /// <summary>
    /// Collects all the bodies. 
    /// Each is expressed as a position with corresponding functionality.
    /// </summary>
    public IReadOnlyDictionary<Vector2, IFunctional> Bodies 
        => (IReadOnlyDictionary<Vector2, IFunctional>)_bodies;
    /// <summary>
    /// Represents the offset from aligned with tile grid.
    /// </summary>
    public Vector2 Offset => _offset;

    public event NotifyCollectionChangedEventHandler BodiesChanged
    {
        add => _bodies.CollectionChanged += value;
        remove => _bodies.CollectionChanged -= value;
    }
    public void AssignBody(Vector2 position, IFunctional functionality)
        => _bodies.Add(new KeyValuePair<Vector2, IFunctional>(Floor(position), functionality));
    public void RemoveBody(Vector2 position, IFunctional functionality)
        => _bodies.Remove(new KeyValuePair<Vector2, IFunctional>(position, functionality));
    public void RemoveBody(Vector2 position)
    {
        foreach(KeyValuePair<Vector2, IFunctional> body in _bodies)
        {
            if (body.Key == position) _bodies.Remove(body);
        }
    }
    public void RemoveBody(IFunctional functionality)
    {
        foreach(KeyValuePair<Vector2, IFunctional> body in _bodies)
        {
            if (body.Value == functionality) _bodies.Remove(body);
        }
    }
    public void Move(Vector2 distance)
    {
        _offset += distance;
        while (_offset.X < OffsetMin)
            ShiftOffset(Directions.Right);
        while (_offset.Y < OffsetMin)
            ShiftOffset(Directions.Down);
        while (_offset.X >= OffsetMax)
            ShiftOffset(Directions.Left);
        while (_offset.Y >= OffsetMax)
            ShiftOffset(Directions.Up);
    }

    private ObservableCollection<KeyValuePair<Vector2, IFunctional>> _bodies { get; }
    private Vector2 _offset = Vector2.Zero;
    private void ShiftOffset(Directions shiftDirection)
    {
        Vector2 shiftVector = shiftDirection.DirectionsToVector2();
        _offset += shiftVector;
        foreach (KeyValuePair<Vector2, IFunctional> body in _bodies)
        {
            _bodies.Remove(body);
            _bodies.Add(new KeyValuePair<Vector2, IFunctional>(body.Key + -shiftVector, body.Value));
        }
    }

    private static Vector2 Floor(Vector2 vector)
        => new((float)System.Math.Floor(vector.X), (float)System.Math.Floor(vector.Y));
    private const float OffsetMargin = 0.1f;
    private const float OffsetMin = 0.0f - OffsetMargin;
    private const float OffsetMax = 1.0f + OffsetMargin;
}
