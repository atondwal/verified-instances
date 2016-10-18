{-@ LIQUID "--higherorder"        @-}
{-@ LIQUID "--totality"           @-}
{-@ LIQUID "--exactdc"            @-}

module Data.VerifiedOrd.Instances.Sum (vordSum) where

import Data.VerifiedEq
import Data.VerifiedOrd
import Data.VerifiedEq.Instances
import Data.VerifiableConstraint
import Language.Haskell.Liquid.ProofCombinators

{-@ data Either a b = Left a | Right b @-}

{-@ axiomatize leqSum @-}
leqSum :: (a -> a -> Bool) -> (b -> b -> Bool)
       -> Either a b -> Either a b -> Bool
leqSum leqa leqb (Left x) (Left y) = leqa x y
leqSum leqa leqb (Left x) (Right y) = True
leqSum leqa leqb (Right x) (Left y) = False
leqSum leqa leqb (Right x) (Right y) = leqb x y
{-# INLINE leqSum #-}

{-@ leqSumRefl :: leqa:(a -> a -> Bool) -> leqaRefl:(x:a -> { Prop (leqa x x) })
               -> leqb:(b -> b -> Bool) -> leqbRefl:(y:b -> { Prop (leqb y y) })
               -> p:Either a b
               -> { leqSum leqa leqb p p }
@-}
leqSumRefl :: (a -> a -> Bool) -> (a -> Proof)
           -> (b -> b -> Bool) -> (b -> Proof)
           -> Either a b -> Proof
leqSumRefl leqa leqaRefl leqb leqbRefl p@(Left x) =
      leqSum leqa leqb p p
  ==. leqa x x
  ==. True ? leqaRefl x
  *** QED
leqSumRefl leqa leqaRefl leqb leqbRefl p@(Right y) =
      leqSum leqa leqb p p
  ==. leqb y y
  ==. True ? leqbRefl y
  *** QED

{-@ leqSumTotal :: leqa:(a -> a -> Bool) -> leqaTotal:(x:a -> y:a -> { Prop (leqa x y) || Prop (leqa y x) })
                -> leqb:(b -> b -> Bool) -> leqbTotal:(x:b -> y:b -> { Prop (leqb x y) || Prop (leqb y x) })
                -> p:Either a b -> q:Either a b
                -> { leqSum leqa leqb p q || leqSum leqa leqb q p }
@-}
leqSumTotal :: (a -> a -> Bool) -> (a -> a -> Proof)
            -> (b -> b -> Bool) -> (b -> b -> Proof)
            -> Either a b -> Either a b -> Proof
leqSumTotal leqa leqaTotal leqb leqbTotal p@(Left x) q@(Left y) =
      (leqSum leqa leqb p q || leqSum leqa leqb q p)
  ==. (leqa x y || leqa y x)
  ==. True ? leqaTotal x y
  *** QED
leqSumTotal leqa leqaTotal leqb leqbTotal p@(Left x) q@(Right y) =
      (leqSum leqa leqb p q || leqSum leqa leqb q p)
  ==. (True || True)
  *** QED
leqSumTotal leqa leqaTotal leqb leqbTotal p@(Right x) q@(Left y) =
      (leqSum leqa leqb p q || leqSum leqa leqb q p)
  ==. (False || False)
  *** QED
leqSumTotal leqa leqaTotal leqb leqbTotal p@(Right x) q@(Right y) =
      (leqSum leqa leqb p q || leqSum leqa leqb q p)
  ==. (leqb x y || leqb y x)
  ==. True ? leqbTotal x y
  *** QED

{-@ leqSumAntisym :: leqa:(a -> a -> Bool) -> leqaAntisym:(x:a -> y:a -> { Prop (leqa x y) && Prop (leqa y x) ==> x == y })
                  -> leqb:(b -> b -> Bool) -> leqbAntisym:(x:b -> y:b -> { Prop (leqb x y) && Prop (leqb y x) ==> x == y })
                  -> VerifiedEq a -> VerifiedEq b
                  -> p:Either a b -> q:Either a b
                  -> { leqSum leqa leqb p q && leqSum leqa leqb q p ==> p == q }
@-}
leqSumAntisym :: (a -> a -> Bool) -> (a -> a -> Proof)
              -> (b -> b -> Bool) -> (b -> b -> Proof)
              -> VerifiedEq a -> VerifiedEq b
              -> Either a b -> Either a b -> Proof
leqSumAntisym leqa leqaAntisym leqb leqbAntisym veqa veqb p@(Left x) q@(Left y) =
      using (VEq veqa)
    $ (leqSum leqa leqb p q && leqSum leqa leqb q p)
  ==. (leqa x y && leqa y x)
  ==. x == y ? leqaAntisym x y
  *** QED
leqSumAntisym leqa leqaAntisym leqb leqbAntisym veqa veqb p@(Left x) q@(Right y) =
      using (VEq veqa)
    $ using (VEq veqb)
    $ (leqSum leqa leqb p q && leqSum leqa leqb q p)
  ==. (True && False)
  ==. False
  ==. p == q
  *** QED
leqSumAntisym leqa leqaAntisym leqb leqbAntisym veqa veqb p@(Right x) q@(Left y) =
      using (VEq veqa)
    $ using (VEq veqb)
    $ (leqSum leqa leqb p q && leqSum leqa leqb q p)
  ==. (False && True)
  ==. False
  ==. p == q
  *** QED
leqSumAntisym leqa leqaAntisym leqb leqbAntisym veqa veqb p@(Right x) q@(Right y) =
      using (VEq veqb)
    $ (leqSum leqa leqb p q && leqSum leqa leqb q p)
  ==. (leqb x y && leqb y x)
  ==. x == y ? leqbAntisym x y
  *** QED

{-@ leqSumTrans :: leqa:(a -> a -> Bool) -> leqaTrans:(x:a -> y:a -> z:a -> { Prop (leqa x y) && Prop (leqa y z) ==> Prop (leqa x z) })
                -> leqb:(b -> b -> Bool) -> leqbTrans:(x:b -> y:b -> z:b -> { Prop (leqb x y) && Prop (leqb y z) ==> Prop (leqb x z) })
                -> p:Either a b -> q:Either a b -> r:Either a b
                -> { leqSum leqa leqb p q && leqSum leqa leqb q r ==> leqSum leqa leqb p r }
@-}
leqSumTrans :: (a -> a -> Bool) -> (a -> a -> a -> Proof)
            -> (b -> b -> Bool) -> (b -> b -> b -> Proof)
            -> Either a b -> Either a b -> Either a b -> Proof
leqSumTrans leqa leqaTrans leqb leqbTrans p@(Left x) q@(Left y) r@(Left z) =
      (leqSum leqa leqb p q && leqSum leqa leqb q r)
  ==. (leqa x y && leqa y z)
  ==. leqa x z ? leqaTrans x y z
  ==. leqSum leqa leqb p r
  *** QED
leqSumTrans leqa leqaTrans leqb leqbTrans p@(Left x) q@(Left y) r@(Right z) =
      (leqSum leqa leqb p q && leqSum leqa leqb q r)
  ==. (leqa x y && True)
  ==. leqSum leqa leqb p r
  *** QED
leqSumTrans leqa leqaTrans leqb leqbTrans p@(Left x) q@(Right y) r@(Left z) =
      (leqSum leqa leqb p q && leqSum leqa leqb q r)
  ==. (True && False)
  ==. leqSum leqa leqb p r
  *** QED
leqSumTrans leqa leqaTrans leqb leqbTrans p@(Left x) q@(Right y) r@(Right z) =
      (leqSum leqa leqb p q && leqSum leqa leqb q r)
  ==. (True && leqb y z)
  ==. leqSum leqa leqb p r
  *** QED
leqSumTrans leqa leqaTrans leqb leqbTrans p@(Right x) q@(Left y) r@(Left z) =
      (leqSum leqa leqb p q && leqSum leqa leqb q r)
  ==. (False && leqa y z)
  ==. leqSum leqa leqb p r
  *** QED
leqSumTrans leqa leqaTrans leqb leqbTrans p@(Right x) q@(Left y) r@(Right z) =
      (leqSum leqa leqb p q && leqSum leqa leqb q r)
  ==. (False && True)
  ==. leqSum leqa leqb p r
  *** QED
leqSumTrans leqa leqaTrans leqb leqbTrans p@(Right x) q@(Right y) r@(Left z) =
      (leqSum leqa leqb p q && leqSum leqa leqb q r)
  ==. (leqb x y && False)
  ==. leqSum leqa leqb p r
  *** QED
leqSumTrans leqa leqaTrans leqb leqbTrans p@(Right x) q@(Right y) r@(Right z) =
      (leqSum leqa leqb p q && leqSum leqa leqb q r)
  ==. (leqb x y && leqb y z)
  ==. leqb x z ? leqbTrans x y z
  ==. leqSum leqa leqb p r
  *** QED

vordSum :: VerifiedOrd a -> VerifiedOrd b -> VerifiedOrd (Either a b)
vordSum (VerifiedOrd leqa leqaTotal leqaAntisym leqaTrans veqa) (VerifiedOrd leqb leqbTotal leqbAntisym leqbTrans veqb) =
  VerifiedOrd
    (leqSum leqa leqb)
    (leqSumTotal leqa leqaTotal leqb leqbTotal)
    (leqSumAntisym leqa leqaAntisym leqb leqbAntisym veqa veqb)
    (leqSumTrans leqa leqaTrans leqb leqbTrans)
    (veqSum veqa veqb)