# TODO: Test two levels of nesting arrays
# TODO: Test moving arrays

# TODO: Can this code be refactored? Feels repetative


# Keeps track of each unique path via an id
module.exports = PathMap = ->
  @clear()
  return

PathMap:: =
  clear: ->
    @count = 0
    @ids = {}
    @paths = {}
    @arrays = {}
    return

  id: (path) ->
    # Return the path for an id, or create a new id and index it
    this.ids[path] || (
      this.paths[id = ++@count] = path
      @_indexArray path, id
      this.ids[path] = id
    )

  _indexArray: (path, id) ->
    while match = /^(.+)\.(\d+)(\..+|$)/.exec path
      path = match[1]
      index = +match[2]
      remainder = match[3]
      arr = @arrays[path] || @arrays[path] = []
      set = arr[index] || arr[index] = {}
      if nested
        setArrays = set.arrays || set.arrays = {}
        setArrays[remainder] = true
      else
        set[id] = remainder
      nested = true
    return

  _incrementItems: (path, map, start, end, byNum) ->
    for i in [start...end]
      continue unless ids = map[i]
      for id, remainder of ids
        if id is 'arrays'
          for remainder of ids[id]
            arrayPath = path + '.' + i + remainder
            arrayPathTo = path + '.' + (i + byNum) + remainder
            arrayMap = @arrays[arrayPath]
            @arrays[arrayPathTo] = arrayMap
            delete @arrays[arrayPath]
            @_incrementItems arrayPathTo, arrayMap, 0, arrayMap.length, 0
          continue
        itemPath = path + '.' + (i + byNum) + remainder
        @paths[id] = itemPath
        @ids[itemPath] = +id
    return

  _deleteItems: (path, map, start, end) ->
    for i in [start...map.length]
      continue unless ids = map[i]
      for id of ids
        if id is 'arrays'
          for remainder of ids[id]
            arrayPath = path + '.' + i + remainder
            arrayMap = @arrays[arrayPath]
            @_deleteItems arrayPath, arrayMap, 0, arrayMap.length
            continue if i > end
            delete @arrays[arrayPath]
          continue
        itemPath = @paths[id]
        delete @ids[itemPath]
        continue if i > end
        delete @paths[id]
    return
  
  onRemove: (path, start, howMany) ->
    return unless map = @arrays[path]
    end = start + howMany
    # Delete indicies for removed items
    @_deleteItems path, map, start, end + 1
    if end < len = map.length
      # Decrement indicies of later items
      @_incrementItems path, map, end, len, -howMany
    map.splice start, howMany
    return
  
  onInsert: (path, start, howMany) ->
    return unless map = @arrays[path]
    end = start + howMany
    if start < len = map.length
      # Delete indicies for items in inserted positions
      @_deleteItems path, map, start, end + 1
      # Increment indicies of later items
      @_incrementItems path, map, start, len, howMany
    map.splice start, 0, {}  while howMany--
    return

  onMove: (path, from, to) ->
    return unless map = @arrays[path]
    # Adjust paths for the moved item
    @_incrementItems path, map, from, from + 1, to - from
    # Adjust paths for items between from and to
    if from > to
      @_incrementItems path, map, to, from, 1
    else
      @_incrementItems path, map, from + 1, to + 1, -1
    # Fix the array index
    [item] = map.splice from, 1
    map.splice to, 0, item
    return
