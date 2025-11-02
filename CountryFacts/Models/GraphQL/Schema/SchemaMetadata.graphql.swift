// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

protocol CountryFactsSchema_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == CountryFactsSchema.SchemaMetadata {}

protocol CountryFactsSchema_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == CountryFactsSchema.SchemaMetadata {}

protocol CountryFactsSchema_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == CountryFactsSchema.SchemaMetadata {}

protocol CountryFactsSchema_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == CountryFactsSchema.SchemaMetadata {}

extension CountryFactsSchema {
  typealias SelectionSet = CountryFactsSchema_SelectionSet

  typealias InlineFragment = CountryFactsSchema_InlineFragment

  typealias MutableSelectionSet = CountryFactsSchema_MutableSelectionSet

  typealias MutableInlineFragment = CountryFactsSchema_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "Continent": return CountryFactsSchema.Objects.Continent
      case "Country": return CountryFactsSchema.Objects.Country
      case "Language": return CountryFactsSchema.Objects.Language
      case "Query": return CountryFactsSchema.Objects.Query
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}