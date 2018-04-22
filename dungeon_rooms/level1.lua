return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "1.1.4",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 10,
  height = 10,
  tilewidth = 16,
  tileheight = 16,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "dungeon_room_numbers",
      firstgid = 1,
      filename = "dungeon_room_numbers.tsx",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      image = "dungeon_room_numbers.png",
      imagewidth = 640,
      imageheight = 400,
      transparentcolor = "#eeeeec",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      terrains = {},
      tilecount = 1000,
      tiles = {
        {
          id = 0,
          properties = {
            ["name"] = "dungeon_rooms/dungeon1.lua"
          }
        },
        {
          id = 1,
          properties = {
            ["name"] = "dungeon_rooms/dungeon2.lua"
          }
        },
        {
          id = 2,
          properties = {
            ["name"] = "dungeon_rooms/dungeon3.lua"
          }
        },
        {
          id = 3,
          properties = {
            ["name"] = "dungeon_rooms/dungeon4.lua"
          }
        },
        {
          id = 4,
          properties = {
            ["name"] = "dungeon_rooms/dungeon5.lua"
          }
        },
        {
          id = 5,
          properties = {
            ["name"] = "dungeon_rooms/dungeon6.lua"
          }
        },
        {
          id = 6,
          properties = {
            ["name"] = "dungeon_rooms/dungeon7.lua"
          }
        },
        {
          id = 7,
          properties = {
            ["name"] = "dungeon_rooms/dungeon8.lua"
          }
        },
        {
          id = 8,
          properties = {
            ["name"] = "dungeon_rooms/dungeon9.lua"
          }
        },
        {
          id = 9,
          properties = {
            ["name"] = "dungeon_rooms/dungeon0.lua"
          }
        }
      }
    },
    {
      name = "dungeon_room_behaviors",
      firstgid = 1001,
      filename = "dungeon_room_behaviors.tsx",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      image = "dungeon_room_behaviors.png",
      imagewidth = 640,
      imageheight = 400,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      terrains = {},
      tilecount = 1000,
      tiles = {
        {
          id = 0,
          properties = {
            ["name"] = "start"
          }
        },
        {
          id = 1,
          properties = {
            ["name"] = "end"
          }
        },
        {
          id = 2,
          properties = {
            ["clickable"] = "false",
            ["name"] = "unexplored"
          }
        },
        {
          id = 3,
          properties = {
            ["clickable"] = "true",
            ["name"] = "explored"
          }
        },
        {
          id = 4,
          properties = {
            ["clickable"] = "true",
            ["name"] = "explorable"
          }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "dungeon_room_numbers",
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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 10, 9, 0, 0, 0, 0, 0, 7,
        0, 0, 0, 8, 7, 4, 5, 6, 9, 8,
        0, 0, 6, 5, 0, 3, 0, 10, 0, 0,
        0, 0, 0, 0, 0, 2, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      name = "dungeon_room_unexplored",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003,
        1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003,
        1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003,
        1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003,
        1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003,
        1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003,
        1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003,
        1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003,
        1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003,
        1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003, 1003
      }
    },
    {
      type = "tilelayer",
      name = "dungeon_room_explorable",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 1005, 1005, 0, 0, 0, 0, 0, 1005,
        0, 0, 0, 1005, 1005, 1005, 1005, 1005, 1005, 1005,
        0, 0, 1005, 1005, 0, 1005, 0, 1005, 0, 0,
        0, 0, 0, 0, 0, 1005, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 1005, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      name = "dungeon_room_explored",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 1004, 1004, 0, 0, 0, 0, 0, 1004,
        0, 0, 0, 1004, 1004, 1004, 1004, 1004, 1004, 1004,
        0, 0, 1004, 1004, 0, 1004, 0, 1004, 0, 0,
        0, 0, 0, 0, 0, 1004, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 1004, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      name = "dungeon_room_behaviors",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1002,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 1001, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    }
  }
}
