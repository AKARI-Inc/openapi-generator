{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# OPTIONS_GHC -fno-warn-unused-binds -fno-warn-unused-imports #-}

module OpenAPIPetstore.Types (
  ApiResponse (..),
  Category (..),
  Order (..),
  Pet (..),
  Tag (..),
  User (..),
  ) where

import Data.Data (Data)
import Data.UUID (UUID)
import Data.List (stripPrefix)
import Data.Maybe (fromMaybe)
import Data.Aeson (Value, FromJSON(..), ToJSON(..), genericToJSON, genericParseJSON)
import Data.Aeson.Types (Options(..), defaultOptions)
import Data.Set (Set)
import Data.Text (Text)
import Data.Time
import Data.Swagger (ToSchema, declareNamedSchema)
import qualified Data.Swagger as Swagger
import qualified Data.Char as Char
import qualified Data.Text as T
import qualified Data.Map as Map
import GHC.Generics (Generic)
import Data.Function ((&))


-- | Describes the result of uploading an image resource
data ApiResponse = ApiResponse
  { apiResponseCode :: Maybe Int -- ^ 
  , apiResponseType :: Maybe Text -- ^ 
  , apiResponseMessage :: Maybe Text -- ^ 
  } deriving (Show, Eq, Generic, Data)

instance FromJSON ApiResponse where
  parseJSON = genericParseJSON (removeFieldLabelPrefix "apiResponse")
instance ToJSON ApiResponse where
  toJSON = genericToJSON (removeFieldLabelPrefix "apiResponse")
instance ToSchema ApiResponse where
  declareNamedSchema = Swagger.genericDeclareNamedSchema
    $ Swagger.fromAesonOptions
    $ removeFieldLabelPrefix "apiResponse"


-- | A category for a pet
data Category = Category
  { categoryId :: Maybe Integer -- ^ 
  , categoryName :: Maybe Text -- ^ 
  } deriving (Show, Eq, Generic, Data)

instance FromJSON Category where
  parseJSON = genericParseJSON (removeFieldLabelPrefix "category")
instance ToJSON Category where
  toJSON = genericToJSON (removeFieldLabelPrefix "category")
instance ToSchema Category where
  declareNamedSchema = Swagger.genericDeclareNamedSchema
    $ Swagger.fromAesonOptions
    $ removeFieldLabelPrefix "category"


-- | An order for a pets from the pet store
data Order = Order
  { orderId :: Maybe Integer -- ^ 
  , orderPetId :: Maybe Integer -- ^ 
  , orderQuantity :: Maybe Int -- ^ 
  , orderShipDate :: Maybe UTCTime -- ^ 
  , orderStatus :: Maybe Text -- ^ Order Status
  , orderComplete :: Maybe Bool -- ^ 
  } deriving (Show, Eq, Generic, Data)

instance FromJSON Order where
  parseJSON = genericParseJSON (removeFieldLabelPrefix "order")
instance ToJSON Order where
  toJSON = genericToJSON (removeFieldLabelPrefix "order")
instance ToSchema Order where
  declareNamedSchema = Swagger.genericDeclareNamedSchema
    $ Swagger.fromAesonOptions
    $ removeFieldLabelPrefix "order"


-- | A pet for sale in the pet store
data Pet = Pet
  { petId :: Maybe Integer -- ^ 
  , petCategory :: Maybe Category -- ^ 
  , petName :: Text -- ^ 
  , petPhotoUrls :: [Text] -- ^ 
  , petTags :: Maybe [Tag] -- ^ 
  , petStatus :: Maybe Text -- ^ pet status in the store
  } deriving (Show, Eq, Generic, Data)

instance FromJSON Pet where
  parseJSON = genericParseJSON (removeFieldLabelPrefix "pet")
instance ToJSON Pet where
  toJSON = genericToJSON (removeFieldLabelPrefix "pet")
instance ToSchema Pet where
  declareNamedSchema = Swagger.genericDeclareNamedSchema
    $ Swagger.fromAesonOptions
    $ removeFieldLabelPrefix "pet"


-- | A tag for a pet
data Tag = Tag
  { tagId :: Maybe Integer -- ^ 
  , tagName :: Maybe Text -- ^ 
  } deriving (Show, Eq, Generic, Data)

instance FromJSON Tag where
  parseJSON = genericParseJSON (removeFieldLabelPrefix "tag")
instance ToJSON Tag where
  toJSON = genericToJSON (removeFieldLabelPrefix "tag")
instance ToSchema Tag where
  declareNamedSchema = Swagger.genericDeclareNamedSchema
    $ Swagger.fromAesonOptions
    $ removeFieldLabelPrefix "tag"


-- | A User who is purchasing from the pet store
data User = User
  { userId :: Maybe Integer -- ^ 
  , userUsername :: Maybe Text -- ^ 
  , userFirstName :: Maybe Text -- ^ 
  , userLastName :: Maybe Text -- ^ 
  , userEmail :: Maybe Text -- ^ 
  , userPassword :: Maybe Text -- ^ 
  , userPhone :: Maybe Text -- ^ 
  , userUserStatus :: Maybe Int -- ^ User Status
  } deriving (Show, Eq, Generic, Data)

instance FromJSON User where
  parseJSON = genericParseJSON (removeFieldLabelPrefix "user")
instance ToJSON User where
  toJSON = genericToJSON (removeFieldLabelPrefix "user")
instance ToSchema User where
  declareNamedSchema = Swagger.genericDeclareNamedSchema
    $ Swagger.fromAesonOptions
    $ removeFieldLabelPrefix "user"


uncapitalize :: String -> String
uncapitalize (first:rest) = Char.toLower first : rest
uncapitalize [] = []

-- | Remove a field label prefix during JSON parsing.
--   Also perform any replacements for special characters.
removeFieldLabelPrefix :: String -> Options
removeFieldLabelPrefix prefix =
  defaultOptions
    { omitNothingFields  = True
    , fieldLabelModifier = uncapitalize . replaceSpecialChars . fromMaybe (error ("did not find prefix " ++ prefix)) . stripPrefix prefix
    }
  where
    replaceSpecialChars field = foldl (&) field (map mkCharReplacement specialChars)
    specialChars =
      [ ("$", "Dollar")
      , ("^", "Caret")
      , ("|", "Pipe")
      , ("=", "Equal")
      , ("*", "Star")
      , ("-", "Dash")
      , ("&", "Ampersand")
      , ("%", "Percent")
      , ("#", "Hash")
      , ("@", "At")
      , ("!", "Exclamation")
      , ("+", "Plus")
      , (":", "Colon")
      , (";", "Semicolon")
      , (">", "GreaterThan")
      , ("<", "LessThan")
      , (".", "Period")
      , ("_", "Underscore")
      , ("?", "Question_Mark")
      , (",", "Comma")
      , ("'", "Quote")
      , ("/", "Slash")
      , ("(", "Left_Parenthesis")
      , (")", "Right_Parenthesis")
      , ("{", "Left_Curly_Bracket")
      , ("}", "Right_Curly_Bracket")
      , ("[", "Left_Square_Bracket")
      , ("]", "Right_Square_Bracket")
      , ("~", "Tilde")
      , ("`", "Backtick")
      , ("<=", "Less_Than_Or_Equal_To")
      , (">=", "Greater_Than_Or_Equal_To")
      , ("!=", "Not_Equal")
      , ("<>", "Not_Equal")
      , ("~=", "Tilde_Equal")
      , ("\\", "Back_Slash")
      , ("\"", "Double_Quote")
      ]
    mkCharReplacement (replaceStr, searchStr) = T.unpack . T.replace (T.pack searchStr) (T.pack replaceStr) . T.pack
