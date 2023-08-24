using System.Collections.Generic;

namespace Foliage.BoardElement;

public interface ILayered
{
    /// <summary>
    /// Holds the names of all layers linked.
    /// </summary>
    List<string> Layers { get; set; }
}
