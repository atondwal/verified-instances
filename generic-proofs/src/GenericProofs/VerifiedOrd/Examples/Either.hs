{-@ LIQUID "--higherorder"        @-}
{-@ LIQUID "--totality"           @-}
{-@ LIQUID "--exactdc"            @-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies    #-}
module GenericProofs.VerifiedOrd.Examples.Either
  ( Either(..)
  , RepEither
  , toEither
  , fromEither
  , tofEither
  , fotEither
  , isoEither
  , vordEither
  ) where

import Language.Haskell.Liquid.ProofCombinators

import GenericProofs.Iso
import GenericProofs.TH
import GenericProofs.VerifiedOrd
import GenericProofs.VerifiedOrd.Generics
import GenericProofs.VerifiedOrd.Instances

import Generics.Deriving.Newtypeless.Base.Internal

import Prelude                                     hiding (Either (..))

-- Morally a newtype, but in practice, not.
{-@ data Either a b = L a | R b @-}
data Either a b = L a | R b deriving (Eq)

{-@ axiomatize fromEither @-}
{-@ axiomatize toEither @-}
{-@ tofEither :: a:Either a b
             -> { toEither (fromEither a) == a }
@-}
{-@ fotEither :: a:RepEither a b x
             -> { fromEither (toEither a) == a }
@-}
$(deriveIso "RepEither"
            "toEither" "fromEither"
            "tofEither" "fotEither"
            "isoEither"
            ''Either)

vordEither :: VerifiedOrd (Either Int Double)
vordEither = vordIso (isoSym isoEither)
           $ vordM1 $ vordSum (vordM1 $ vordM1 $ vordK1 vordInt)
                              (vordM1 $ vordM1 $ vordK1 vordDouble)
