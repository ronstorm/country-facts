// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension CountryFactsSchema {
  class GetCountryDetailQuery: GraphQLQuery {
    static let operationName: String = "GetCountryDetail"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query GetCountryDetail($code: ID!) { country(code: $code) { __typename code name native emoji continent { __typename code name } capital currency languages { __typename code name } } }"#
      ))

    public var code: ID

    public init(code: ID) {
      self.code = code
    }

    public var __variables: Variables? { ["code": code] }

    struct Data: CountryFactsSchema.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { CountryFactsSchema.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("country", Country?.self, arguments: ["code": .variable("code")]),
      ] }

      var country: Country? { __data["country"] }

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
          .field("native", String.self),
          .field("emoji", String.self),
          .field("continent", Continent.self),
          .field("capital", String?.self),
          .field("currency", String?.self),
          .field("languages", [Language].self),
        ] }

        var code: CountryFactsSchema.ID { __data["code"] }
        var name: String { __data["name"] }
        var native: String { __data["native"] }
        var emoji: String { __data["emoji"] }
        var continent: Continent { __data["continent"] }
        var capital: String? { __data["capital"] }
        var currency: String? { __data["currency"] }
        var languages: [Language] { __data["languages"] }

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

        /// Country.Language
        ///
        /// Parent Type: `Language`
        struct Language: CountryFactsSchema.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { CountryFactsSchema.Objects.Language }
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