{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Week02.Homework2 where

import Control.Monad hiding (fmap)
import Data.Aeson (FromJSON, ToJSON)
import Data.Map as Map
import Data.Text (Text)
import Data.Void (Void)
import GHC.Generics (Generic)
import Ledger hiding (singleton)
import Ledger.Ada as Ada
import Ledger.Constraints as Constraints
import qualified Ledger.Scripts as Scripts
import qualified Ledger.Typed.Scripts as Scripts
import Playground.Contract (ToSchema, ensureKnownCurrencies, printJson, printSchemas, stage)
import Playground.TH (mkKnownCurrencies, mkSchemaDefinitions)
import Playground.Types (KnownCurrency (..))
import Plutus.Contract hiding (when)
import PlutusTx (Data (..))
import qualified PlutusTx
import PlutusTx.Prelude hiding (Semigroup (..), unless)
import Text.Printf (printf)
import Prelude (Semigroup (..))

data MyRedeemer = MyRedeemer -- Creating a record (an object) that takes in 2 booleans
  { flag1 :: Bool,
    flag2 :: Bool
  }
  deriving (Generic, FromJSON, ToJSON, ToSchema)

PlutusTx.unstableMakeIsData ''MyRedeemer

{-# INLINEABLE mkValidator #-}
-- This should validate if and only if the two Booleans in the redeemer are equal!
mkValidator :: () -> MyRedeemer -> ScriptContext -> Bool
mkValidator _ (MyRedeemer a b) _ = traceIfFalse "Redeemer booleans are not equal" $ a == b -- FIX ME!

data Typed

instance Scripts.ScriptType Typed where
  type DatumType Typed = ()
  type RedeemerType Typed = MyRedeemer

-- Implement me!

inst :: Scripts.ScriptInstance Typed
inst =
  Scripts.validator @Typed
    $$(PlutusTx.compile [||mkValidator||])
    $$(PlutusTx.compile [||wrap||])
  where
    wrap = Scripts.wrapValidator @() @MyRedeemer

validator :: Validator
validator = Scripts.validatorScript inst

scrAddress :: Ledger.Address
scrAddress = scriptAddress validator -- FIX ME!

type GiftSchema =
  BlockchainActions
    .\/ Endpoint "give" Integer
    .\/ Endpoint "grab" MyRedeemer

give :: (HasBlockchainActions s, AsContractError e) => Integer -> Contract w s e ()
give amount = do
  let tx = mustPayToTheScript () $ Ada.lovelaceValueOf amount
  ledgerTx <- submitTxConstraints inst tx
  void $ awaitTxConfirmed $ txId ledgerTx
  logInfo @String $ printf "made a gift of %d lovelace" amount

grab :: forall w s e. (HasBlockchainActions s, AsContractError e) => MyRedeemer -> Contract w s e ()
grab r = do
  utxos <- utxoAt scrAddress
  let orefs = fst <$> Map.toList utxos
      lookups =
        Constraints.unspentOutputs utxos
          <> Constraints.otherScript validator
      tx :: TxConstraints Void Void
      tx = mconcat [mustSpendScriptOutput oref $ Redeemer $ PlutusTx.toData r | oref <- orefs]
  ledgerTx <- submitTxConstraintsWith @Void lookups tx
  void $ awaitTxConfirmed $ txId ledgerTx
  logInfo @String $ "collected gifts"

endpoints :: Contract () GiftSchema Text ()
endpoints = (give' `select` grab') >> endpoints
  where
    give' = endpoint @"give" >>= give
    grab' = endpoint @"grab" >>= grab

mkSchemaDefinitions ''GiftSchema

mkKnownCurrencies []
