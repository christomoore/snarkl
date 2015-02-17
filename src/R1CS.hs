{-# LANGUAGE GADTs #-}

module R1CS
  ( Field
  , Poly
  , Var
  , R1C(..)
  , R1CS(..)
  , sat_r1cs
  , num_constraints
  ) where

import qualified Data.Map.Strict as Map

import Common
import Field
import Poly

----------------------------------------------------------------
--                Rank-1 Constraint Systems                   --
----------------------------------------------------------------

data R1C a where
  R1C :: Field a => (Poly a, Poly a, Poly a) -> R1C a

instance Show a => Show (R1C a) where
  show (R1C (aV,bV,cV)) = show aV ++ "*" ++ show bV ++ "==" ++ show cV

data R1CS a where
  R1CS :: Field a => [R1C a] -> R1CS a

instance Show a => Show (R1CS a) where
  show (R1CS cs) = show cs

num_constraints :: R1CS a -> Int
num_constraints (R1CS ls) = length ls

-- sat_r1c: Does witness 'w' satisfy constraint 'c'?
sat_r1c :: Field a => Map.Map Var a -> R1C a -> Bool
sat_r1c w c
  | R1C (aV, bV, cV) <- c
  = inner aV w `mult` inner bV w == inner cV w
    where inner :: Field a => Poly a -> Map.Map Var a -> a
          inner (Poly v) w'
            = let c0 = Map.findWithDefault zero (-1) v
              in Map.foldlWithKey (f w') c0 v

          f w' acc v_key v_val
            = (v_val `mult` Map.findWithDefault zero v_key w') `add` acc

-- sat_r1cs: Does witness 'w' satisfy constraint set 'cs'?
sat_r1cs :: Field a => Map.Map Var a -> R1CS a -> Bool
sat_r1cs w cs
  | R1CS cs' <- cs
  = g cs'
    where g [] = True
          g (c : cs'') =
            if sat_r1c w c then g cs''
            else error $ "sat_r1cs: witness failed to satisfy constraint: "
                         ++ show w ++ " " ++ show c


  







