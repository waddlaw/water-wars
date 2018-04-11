{-# LANGUAGE TypeFamilies #-}
module Render.Resources.Tiles (Tile, Tile(..), loadTileMap, setTiles) where

import ClassyPrelude
import qualified Graphics.Gloss as Gloss 
import Render.State

import Codec.Resource 

type TileMap = Map Tile Gloss.Picture

data Tile 
    = Floor
    | EndLeft
    | EndRight
    | BottomLeftCorner
    | BottomRightCorner
    | TopRightCorner
    | TopLeftCorner
    | LeftWall
    | RightWall
    | Middle
    | Ceil
    deriving (Show, Enum, Bounded, Eq, Ord, Read)

setTiles :: TileMap -> Seq Solid
setTiles tilemap =
    fromList ((mapMaybe (\x -> Solid tileSize tileSize (x, fieldHeight) <$> lookup Ceil tilemap) $ [-fieldWidth, (-fieldWidth + tileSize) .. fieldWidth]) -- ceiling placement
    ++ (mapMaybe (\y -> Solid tileSize tileSize (fieldWidth, y) <$> lookup RightWall tilemap) $ [(fieldHeight - tileSize), (fieldHeight - tileSize * 2) .. -fieldHeight]) -- right wall placement
    ++ (mapMaybe (\x -> Solid tileSize tileSize (x, -fieldHeight) <$> lookup Ceil tilemap) $ [-fieldWidth, (-fieldWidth + tileSize) .. fieldWidth]) -- floor placement
    ++ (mapMaybe (\y -> Solid tileSize tileSize (-fieldWidth, y) <$> lookup LeftWall tilemap) $ [-fieldHeight, (-fieldHeight + tileSize) .. fieldHeight]) -- left wall placement
    ++ maybeToList (Solid tileSize tileSize (fieldWidth, -fieldHeight) <$> lookup BottomRightCorner tilemap) -- bottom right corner placement
    ++ maybeToList (Solid tileSize tileSize (fieldWidth, fieldHeight) <$> lookup TopRightCorner tilemap) -- top right corner placement
    ++ maybeToList (Solid tileSize tileSize (-fieldWidth, -fieldHeight) <$> lookup BottomLeftCorner tilemap) -- bottom left corner placement
    ++ maybeToList (Solid tileSize tileSize (-fieldWidth, fieldHeight) <$> lookup TopRightCorner tilemap) -- top left corner placement
    )
        where 
            fieldWidth = 256
            fieldHeight = 256
            tileSize = 32

loadTileMap :: IO (Either String (TileMap))
loadTileMap = do
    loadedTextures <- bulkLoad tiles
    return $ do 
        textures <- loadedTextures
        Right (mapFromList (zip [Floor .. Ceil] (toList textures)))

tiles :: Seq (FilePath, Int, Int)
tiles =
    fromList
        [ ({- Floor,-} "resources/textures/block/block32.png", 32, 32)
        , ({- EndLeft,-} "resources/textures/block/blockendleft32.png", 32, 32)
        , ({- EndRight,-} "resources/textures/block/blockendright32.png", 32, 32)
        , ({- BottomLeftCorner,-} "resources/textures/block/bottomleftcornerblock32.png", 32, 32)
        , ({- BottomRightCorner,-} "resources/textures/block/bottomrightcornerblock32.png", 32, 32)
        , ({- TopRightCorner,-} "resources/textures/block/toprightcornerblock32.png", 32, 32)
        , ({- TopLeftCorner,-} "resources/textures/block/topleftcornerblock32.png", 32, 32)
        , ({- LeftWall,-} "resources/textures/block/leftwallblock32.png", 32, 32)
        , ({- RightWall,-} "resources/textures/block/rightwallblock32.png", 32, 32)
        , ({- Middle,-} "resources/textures/block/middleblock32.png", 32, 32)
        , ({- Ceil,-} "resources/textures/block/topblock32.png", 32, 32)
        ]
    