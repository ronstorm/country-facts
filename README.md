# CountryFacts

CountryFacts is an iOS application that combines data from a public GraphQL API with AI-powered insights to help users explore and learn about countries around the world.

## API Selection

This project uses the following APIs:

### GraphQL API
- **Countries API** - https://countries.trevorblades.com/
  - Chosen from available options: Rick & Morty API, Countries API, SpaceX API
  - Provides country information including names, codes, capitals, currencies, languages, and continents
  - No authentication required
  - Free public API

### LLM API
- **Gemini API (Google AI Studio)** - https://ai.google.dev/
  - Chosen from available options: OpenAI API (gpt-3.5-turbo), Cohere API, Gemini API
  - Uses Gemini 2.5 Flash model
  - Free-tier available with usage quotas
  - Used for generating fun facts and answering questions about countries

## Features

### Core Features
- **Country List Display** - Browse all countries with flag emojis and continent information
  - Data fetched from Countries GraphQL API (https://countries.trevorblades.com/)
- **Country Detail View** - Comprehensive information about each country including capital, currency, languages, and continent
  - Detailed data fetched from Countries GraphQL API
- **AI-Powered Fun Facts** - Engaging fun facts generated using Gemini 2.5 Flash LLM
  - Powered by Gemini API (Google AI Studio) - Free tier
- **Search & Filter** - Real-time search by country name, continent, or country code
- **Favorites System** - Save and filter favorite countries (stored locally)
- **Ask a Question** - Interactive Q&A feature powered by Gemini AI
  - Uses Gemini 2.5 Flash model from Google AI Studio

### User Experience
- **Pull-to-Refresh** - Refresh country data with a simple swipe gesture
- **Dark Mode Support** - Beautiful UI that adapts to light and dark modes
- **Loading States** - Skeleton screens and progress indicators
- **Error Handling** - User-friendly error messages with retry functionality

## Architecture

This project follows **MVVM (Model-View-ViewModel)** architecture with clear separation of concerns:

### Architecture Overview

- **SwiftUI Views** - `LaunchScreen`, `CountryListView` & `CountryDetailView`
- **ViewModels** - `CountryListViewModel` & `CountryDetailViewModel`
- **Services** - `CountryService`, `GeminiService` & `FavoritesManager`
- **External APIs** - `GraphQL API` & `Gemini API`

### Layer Responsibilities

- **Models** - Pure data structures (`Country`, `CountryDetail`) that conform to `Codable`, `Sendable`, and `Identifiable`
- **Views** - SwiftUI views for presentation only, no business logic
- **ViewModels** - Business logic, state management, and coordination between views and services
  - Marked with `@Observable` (iOS 17+) for reactive updates
  - Use `@MainActor` for UI thread safety
- **Services** - Protocol-based API clients for easy testing and swapping implementations
  - `CountryServiceProtocol` - GraphQL data fetching
  - `LLMServiceProtocol` - AI-powered content generation
  - `FavoritesManagerProtocol` - Local storage management

### Key Design Patterns

- **Dependency Injection** - All services injected via initializers
- **Protocol-Oriented Programming** - Services defined as protocols for testability
- **Async/Await** - Modern Swift concurrency throughout
- **MVVM** - Clear separation between UI and business logic

## 📋 Requirements

- iOS 16.0+
- Xcode 16.0+
- Swift 6.2+
- Apollo iOS SDK 1.25.2+
- Gemini API key (free tier available)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/ronstorm/country-facts.git
cd country-facts
```

### 2. Install Apollo iOS SDK

Add Apollo iOS SDK using Swift Package Manager:

1. Open `CountryFacts.xcodeproj` in Xcode
2. Select the project (blue icon) → Select **CountryFacts** target
3. Go to **Package Dependencies** tab
4. Click **+** button
5. Enter this URL: `https://github.com/apollographql/apollo-ios.git`
6. Select version **1.25.2**
7. Click **Add Package**
8. Ensure **Apollo** product is added to your target
9. Go to **General** tab → **Frameworks, Libraries, and Embedded Content**
10. Verify **Apollo** is listed (if not, click **+** and add it)

### 3. Install Apollo iOS CLI

Download the Apollo iOS CLI binary directly from GitHub:

```bash
# Create bin directory if it doesn't exist
mkdir -p bin

# Download Apollo iOS CLI
curl -L https://github.com/apollographql/apollo-ios/releases/download/1.25.2/apollo-ios-cli.tar.gz -o bin/apollo-ios-cli.tar.gz

# Extract the archive
tar -xzf bin/apollo-ios-cli.tar.gz -C bin/

# Make it executable
chmod +x bin/apollo-ios-cli

# Verify installation
./bin/apollo-ios-cli --version
```

**Note:** Use `./bin/apollo-ios-cli` to run commands from the project root.

### 4. Download GraphQL Schema

Download the schema from the Countries API:

```bash
# From project root
curl -X POST https://countries.trevorblades.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"query IntrospectionQuery { __schema { queryType { name } mutationType { name } subscriptionType { name } types { ...FullType } directives { name description locations args { ...InputValue } } } } fragment FullType on __Type { kind name description fields(includeDeprecated: true) { name description args { ...InputValue } type { ...TypeRef } isDeprecated deprecationReason } inputFields { ...InputValue } interfaces { ...TypeRef } enumValues(includeDeprecated: true) { name description isDeprecated deprecationReason } possibleTypes { ...TypeRef } } fragment InputValue on __InputValue { name description type { ...TypeRef } defaultValue } fragment TypeRef on __Type { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name } } } } } } } } }"}' \
  -o CountryFacts/Models/GraphQL/schema.json
```

### 5. Generate GraphQL Code

Run code generation to create Swift files from your GraphQL queries:

```bash
# From project root
./bin/apollo-ios-cli generate
```

**Note:** The generated files (`CountryFacts/Models/GraphQL/API.swift` and `*.graphql.swift`) are already committed to the repository, so the project builds immediately after clone. You only need to run this if you modify GraphQL queries.

### 6. Configure Gemini API Key

You need a Gemini API key from [Google AI Studio](https://ai.google.dev/).

**Important:** Never commit your API key to git. The `Config.xcconfig` file is already in `.gitignore`.

#### Get Your API Key:

1. Visit [Google AI Studio](https://ai.google.dev/)
2. Sign in with your Google account
3. Click "Get API Key" or navigate to API Keys section
4. Create a new API key (free tier available)
5. Copy your API key

#### Setup Options:

**Using Config.xcconfig (Recommended)**

1. Copy `Config.xcconfig.example` to `Config.xcconfig`:
   ```bash
   cp Config.xcconfig.example Config.xcconfig
   ```

2. Open `Config.xcconfig` and add your API key:
   ```
   GEMINI_API_KEY = YOUR_API_KEY_HERE
   ```

3. The project is already configured to read from `Config.xcconfig` via `Info.plist`

### 7. Build and Run

1. Open `CountryFacts.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (⌘ + R)

## Testing

### Running Tests

**In Xcode:**
- Press `⌘ + U` to run all tests
- Or use Test Navigator (⌘ + 6) to run specific test suites

**Command Line:**
```bash
# Run all tests
xcodebuild test -scheme CountryFacts -destination 'platform=iOS Simulator,name=iPhone 17'

# Run specific test suite
xcodebuild test -scheme CountryFacts -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:CountryFactsTests/CountryListViewModelTests
```

### Test Coverage

The project includes comprehensive unit tests for:

- **ViewModels** - `CountryListViewModelTests`, `CountryDetailViewModelTests`
- **Services** - `GeminiServiceTests`, `MockCountryServiceTests`
- **Error Handling** - `CountryServiceErrorTests`, `LLMServiceErrorTests`
- **Mock Services** - `MockCountryService`, `MockLLMService`, `MockFavoritesManager`

### Test Architecture

- **Mock Services** - Protocol-based mocks for isolated testing
- **URLProtocol Mocking** - Custom `MockURLSession` for network testing
- **Test Helpers** - Reusable utilities in `TestHelpers.swift`

## CI/CD

This project includes a GitHub Actions workflow for automated build and testing:

- **Workflow file:** `.github/workflows/ci.yml`
- **Triggers:** Runs on push and pull requests to `main` and `develop` branches
- **Environment:** macOS 15 with Xcode 16.0
- **Actions:**
  - Builds the iOS project
  - Runs all unit tests
  - Generates code coverage reports

## Known Limitations & Tradeoffs

### API Limitations

- **Countries GraphQL API** (https://countries.trevorblades.com/) - Free public API with limited data depth
  - No population, GDP, or historical data
  - Basic country information only
  - No authentication required (rate limits may apply)
  - Selected from options: Rick & Morty API, Countries API, SpaceX API

- **Gemini API Free Tier** (Google AI Studio) - Rate limits apply
  - Free tier has usage quotas
  - Requests may be throttled during high usage
  - Error handling includes retry logic for transient failures
  - Selected from options: OpenAI API (gpt-3.5-turbo), Cohere API, Gemini API
  - Uses Gemini 2.5 Flash model for fun fact generation and Q&A

### Technical Tradeoffs

- **MVVM over TCA** - Chosen for simplicity
  - Less boilerplate than The Composable Architecture
  - Easier to understand for developers new to the codebase
  - Sufficient for app size and complexity

- **No Offline Caching** - Always requires network
  - Countries data fetched fresh on each app launch
  - Fun facts generated on-demand (not cached)
  - Favorites stored locally but country data requires network

- **UserDefaults for Favorites** - Simple storage solution
  - Suitable for small data sets (country codes)
  - Not suitable for large amounts of data
  - Could be upgraded to Core Data if needed

### Performance Considerations

- **LLM Response Time** - Fun facts take 2-5 seconds to generate
  - Loading states clearly indicated to users
  - Generation happens on-demand (not auto-load)
  - Retry logic included for failures

- **List Rendering** - Optimized with `ForEach` within `List`
  - Handles ~250 countries efficiently
  - Search filtering happens in-memory
  - No pagination needed for current data size
