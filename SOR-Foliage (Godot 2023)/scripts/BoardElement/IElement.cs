using Foliage.Math;
using System.Collections.Generic;

namespace Foliage.BoardElement;

public interface IElement
{
    public List<PlanarBox> Hitbox { get; set; }
}
