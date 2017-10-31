return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "1.0.3",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 10,
  height = 10,
  tilewidth = 32,
  tileheight = 32,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "overworld-tileset",
      firstgid = 1,
      filename = "prototype-overworld.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "tilesets/overworld-tileset.png",
      imagewidth = 512,
      imageheight = 672,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      terrains = {},
      tilecount = 336,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "Below",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 7, 8, 9, 0, 0, 0, 0, 0, 0,
        0, 23, 24, 25, 0, 1, 2, 2, 3, 0,
        0, 39, 40, 41, 0, 17, 18, 18, 19, 0,
        0, 0, 0, 1, 2, 49, 66, 34, 35, 0,
        0, 0, 0, 17, 18, 18, 50, 3, 0, 0,
        0, 0, 0, 33, 34, 65, 18, 19, 0, 0,
        0, 0, 4, 5, 6, 17, 18, 19, 0, 0,
        0, 0, 20, 21, 22, 17, 18, 19, 0, 0,
        0, 0, 36, 37, 38, 33, 34, 35, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      name = "Below-Interact",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 246, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      name = "Player",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = true,
      opacity = 0.57,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 330, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 295, 296, 297, 330, 0, 0,
        0, 0, 0, 0, 311, 312, 313, 0, 0, 0,
        0, 0, 0, 0, 327, 328, 329, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 330, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      name = "Above",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = true,
      opacity = 0.33,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 298, 0, 0, 0, 0, 298, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 314, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 298, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 314, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    }
  }
}
