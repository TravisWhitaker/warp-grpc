{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
-- TODO:
-- * read timeout
-- * proper primitives for streaming
module Network.GRPC.Server
    ( runGrpc
    , UnaryHandler
    , ServerStreamHandler
    , ClientStreamHandler
    -- * registration
    , ServiceHandler
    , unary
    , serverStream
    , clientStream
    -- * registration
    , GRPCStatus (..)
    , throwIO
    , GRPCStatusMessage
    , GRPCStatusCode (..)
    -- * to work directly with WAI
    , grpcApp
    , grpcService
    ) where

import           Control.Exception (throwIO)
import           Network.GRPC.HTTP2.Types (GRPCStatus(..), GRPCStatusCode(..), GRPCStatusMessage)
import           Network.Wai.Handler.WarpTLS (TLSSettings, runTLS)
import           Network.Wai.Handler.Warp (Settings)

import           Network.GRPC.Server.Handlers (UnaryHandler, unary, ServerStreamHandler, serverStream, ClientStreamHandler, clientStream)
import           Network.GRPC.Server.Wai (ServiceHandler(..), grpcApp, grpcService)

-- | Helper to constructs and serve a gRPC over HTTP2 application.
--
-- You may want to use 'grpcApp' for adding middlewares to your gRPC server.
runGrpc
  :: TLSSettings
  -- ^ TLS settings for the HTTP2 server.
  -> Settings
  -- ^ Warp settings.
  -> [ServiceHandler]
  -- ^ List of ServiceHandler. Refer to 'grcpApp'
  -> IO ()
runGrpc tlsSettings settings handlers =
    runTLS tlsSettings settings (grpcApp handlers)
