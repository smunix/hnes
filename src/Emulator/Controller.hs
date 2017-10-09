module Emulator.Controller (
    Key(..)
  , Controller(..)
  , new
  , read
  , write
  , setKeysDown
) where

import           Control.Monad (when)
import           Data.Bits     ((.&.))
import           Data.IORef
import           Data.Word
import           Prelude       hiding (read)

data Key
  = A
  | B
  | Select
  | Start
  | Up
  | Down
  | Left
  | Right
  deriving (Show, Eq, Enum)

data Controller = Controller {
  index    :: IORef Int,
  strobe   :: IORef Word8,
  keysDown :: IORef [Key]
} deriving (Eq)

new :: IO Controller
new = do
  index <- newIORef 0
  strobe <- newIORef 0
  keysDown <- newIORef []
  pure $ Controller index strobe keysDown

read :: Controller -> IO Word8
read c = do
  indexV <- readIORef $ index c
  keysDownV <- readIORef $ keysDown c

  let isKeyDown = elem (toEnum indexV) keysDownV
  let value =  if (indexV < 8 && isKeyDown) then 1 else 0
  modifyIORef' (index c) (+1)

  strobeV <- readIORef $ strobe c
  when (strobeV .&. 1 == 1) $
    modifyIORef' (index c) (const 0)

  pure value

write :: Controller -> Word8 -> IO ()
write c v = do
  modifyIORef' (strobe c) (const v)
  strobeV <- readIORef $ strobe c
  when (strobeV .&. 1 == 1) $
    modifyIORef' (index c) (const 0)

setKeysDown :: Controller -> [Key] -> IO ()
setKeysDown c k = modifyIORef' (keysDown c) (const k)