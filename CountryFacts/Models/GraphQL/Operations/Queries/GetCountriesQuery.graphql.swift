// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension CountryFactsSchema {
  class GetCountriesQuery: GraphQLQuery {
    static let operationName: String = "GetCountries"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query GetCountries { countries { __typename code name emoji continent { __typename code name } } }"#
      ))

    public init() {}

    struct Data: CountryFactsSchema.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { CountryFactsSchema.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("countries", [Country].self),
      ] }

      var countries: [Country] { __data["countries"] }

      /// Country
      ///
      /// Parent Type: `Country`
      struct Country: CountryFactsSchema.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { CountryFactsSchema.Objects.Country }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("code", CountryFactsSchema.ID.self),
          .field("name", String.self),
          .field("emoji", String.self),
          .field("continent", Continent.self),
        ] }

        var code: CountryFactsSchema.ID { __data["code"] }
        var name: String { __data["name"] }
        var emoji: String { __data["emoji"] }
        var continent: Continent { __data["continent"] }

        /// Country.Continent
        ///
        /// Parent Type: `Continent`
        struct Continent: CountryFactsSchema.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { CountryFactsSchema.Objects.Continent }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("code", CountryFactsSchema.ID.self),
            .field("name", String.self),
          ] }

          var code: CountryFactsSchema.ID { __data["code"] }
          var name: String { __data["name"] }
        }
      }
    }
  }

}