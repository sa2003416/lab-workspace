# CMPS 312 Mobile Application Development

## Assessment #1 - Digital Library Management System

**Deadline**: Thursday, September 18, at 3:00 PM

---

You are required to develop a `digital_library` application that manages library resources and member operations. This assignment practices Dart programming features (mixins, extensions, arrow functions, collection methods) and OOP concepts (inheritance, polymorphism, interfaces) while following feature-based Clean Architecture principles. This assignment establishes the foundation for your semester-long digital library project. Focus on creating robust, extensible code that can support future enhancements in Flutter, API integration, and database persistence.

### Project Requirements [100%]

#### 1. Project Setup

Create a Dart project named `digital_library` with the following feature-based Clean Architecture structure:

```
lib/
  features/
    library_items/
      domain/
        entities/       # LibraryItem, Book, AudioBook, Author
        contracts/      # LibraryRepository interface
        mixins/         # Reviewable mixin
      data/
        repositories/   # JsonLibraryRepository implementation
      core/
        utils/          # LibraryItem extensions
    members/
      domain/
        entities/       # Member, StudentMember, FacultyMember  
        contracts/      # MemberRepository interface, Payable interface
      data/
        repositories/   # JsonMemberRepository implementation
      core/
        utils/          # Member extensions
    borrowing/
      domain/
        entities/       # BorrowedItem, Review
        services/       # LibrarySystem (business logic)
assets/
  data/                 # JSON files
```

Copy the provided `data` folder into `assets/data/`:

- `authors.json` - contains author information as an array
- `library-catalog.json` - contains books and audiobooks as an array
- `members.json` - contains sample library members as an array

#### 2. Library Items Feature

##### Domain Layer (`features/library_items/domain/`)

###### Entities

**LibraryItem** (abstract base class in `entities/library_item.dart`):

- Properties: `id` (String), `title` (String), `authors` (List`<Author>`), `publishedYear` (int), `category` (String), `isAvailable` (bool), `coverImageUrl` (String?), `description` (String?)
- Abstract methods: `getItemType()`, `getDisplayInfo()`, `toJson()`, `fromJson()`

**Author** (supporting class in `entities/author.dart`):

- Properties: `id` (String), `name` (String), `profileImageUrl` (String?), `biography` (String?), `birthYear` (int?)
- Methods:
  - `getDisplayName()` - formats name appropriately
  - `toJson()` and `fromJson()` for serialization
  - `calculateAge()` - computes current age if birth year available

**Book** (extends LibraryItem in `entities/book.dart`):

- Additional properties: `pageCount` (int), `isbn` (String), `publisher` (String)
- Override all abstract methods appropriately

**AudioBook** (extends LibraryItem in `entities/audiobook.dart`):

- Additional properties: `duration` (double, hours), `narrator` (String), `fileSize` (double, MB)
- Override all abstract methods appropriately

###### Mixins

**Reviewable** (in `mixins/reviewable.dart`):

- Properties: `reviews` (List`<Review>`)
- Methods:
  - `addReview(Review review)` - validates rating range and prevents duplicate reviews
  - `getAverageRating()` - calculates weighted average, returns 0.0 if no reviews
  - `getReviewCount()` - returns total number of reviews
  - `getTopReviews(int count)` - returns highest-rated reviews, sorted by rating then date
  - `hasReviewFromUser(String userName)` - checks if specific user already reviewed this item

Apply this mixin to all LibraryItem subclasses.

###### Contracts

**LibraryRepository** (abstract class in `contracts/library_repository.dart`):

- `Future<List<LibraryItem>> getAllItems()`
- `Future<LibraryItem> getItem(String id)` - throws exception if not found
- `Future<List<LibraryItem>> searchItems(String query)` - searches title, authors, description
- `Future<List<LibraryItem>> getItemsByCategory(String category)`
- `Future<List<LibraryItem>> getAvailableItems()`
- `Future<List<LibraryItem>> getItemsByAuthor(String authorId)`

##### Data Layer (`features/library_items/data/`)

**JsonLibraryRepository** (in `repositories/json_library_repository.dart`):

- Reads from `assets/data/library-catalog.json` (array of library items)
- Reads from `assets/data/authors.json` (array of authors)
- Uses factory constructors to create appropriate LibraryItem subclasses based on "type" field
- Loads authors first, then matches authorIds in items to create Author objects
- Implements robust error handling for file reading and JSON parsing
- Caches loaded data to avoid repeated file reads

##### Core Layer (`features/library_items/core/`)

**LibraryItemExtensions** (in `utils/library_item_extensions.dart`):
Extensions on `List<LibraryItem>` that require analytical thinking:

- `filterByAuthor(String authorName)` - case-insensitive partial match across all authors
- `filterByCategory(String category)` - exact match, case-insensitive
- `sortByRating()` - sort by average rating descending, then by review count descending for ties
- `groupByCategory()` - returns Map<String, List`<LibraryItem>`> with categories as keys
- `getPopularityScore()` - calculates popularity based on review count and average rating using weighted formula
- `findSimilarItems(LibraryItem item, int maxResults)` - finds items with matching authors or categories, excluding the input item
- `getReadingTimeEstimate()` - estimates reading time: books use page count (250 words/page, 200 words/minute), audiobooks use duration directly
- `analyzeCollectionHealth()` - returns statistics: total items, availability percentage, average rating, categories distribution

#### 3. Members Feature

##### Domain Layer (`features/members/domain/`)

###### Entities

**Member** (abstract base class in `entities/member.dart`):

- Properties: `memberId` (String), `name` (String), `email` (String), `joinDate` (DateTime), `borrowedItems` (List`<BorrowedItem>`), `maxBorrowLimit` (int), `borrowPeriod` (int), `profileImageUrl` (String?)
- Methods:
  - `canBorrowItem(LibraryItem item)` - validates borrowing eligibility (availability, limits, restrictions)
  - `getBorrowingHistory()` - returns all borrowed items (current and past)
  - `getOverdueItems()` - returns currently overdue items
  - `getMembershipSummary()` - returns formatted summary with statistics
- Abstract method: `getMemberType()`

**StudentMember** (extends Member in `entities/student_member.dart`):

- Additional properties: `studentId` (String)
- Default limits: maxBorrowLimit = 5, borrowPeriod = 14 days
- Override `canBorrowItem()` to enforce student-specific restrictions

**FacultyMember** (extends Member in `entities/faculty_member.dart`):

- Additional properties: `department` (String)
- Default limits: maxBorrowLimit = 20, borrowPeriod = 60 days
- Override `canBorrowItem()` to allow extended privileges

###### Contracts

**Payable** (interface in `contracts/payable.dart`):

- `double calculateFees()` - computes total outstanding fees
- `bool payFees(double amount)` - processes payment, returns success status
- Implement in StudentMember: QR 2 per day late fee, maximum QR 50 per item

**MemberRepository** (abstract class in `contracts/member_repository.dart`):

- `Future<List<Member>> getAllMembers()`
- `Future<Member> getMember(String memberId)` - throws exception if not found
- `Future<void> addMember(Member member)` - validates unique ID and email
- `Future<void> updateMember(Member member)`

##### Data Layer (`features/members/data/`)

**JsonMemberRepository** (in `repositories/json_member_repository.dart`):

- Reads from `assets/data/members.json` (array of members)
- Creates appropriate member subtypes based on "type" field
- Handles member data persistence (for updates)

##### Core Layer (`features/members/core/`)

**MemberExtensions** (in `utils/member_extensions.dart`):
Extensions on `List<Member>` requiring analytical thinking:

- `filterByType<T extends Member>()` - generic type filtering
- `getMembersWithOverdueItems()` - filters members with any overdue items
- `calculateTotalFees()` - sums outstanding fees across all payable members
- `analyzeBorrowingPatterns()` - returns insights: most active borrowers, average books per member, popular categories by member type
- `getMembersByActivity(DateTime since)` - returns members who borrowed items since specified date
- `getRiskMembers(int overdueDaysThreshold)` - identifies members with items overdue beyond threshold
- `generateMembershipReport()` - creates comprehensive report with member type distribution, activity levels, fee statistics

#### 4. Borrowing Feature

##### Domain Layer (`features/borrowing/domain/`)

###### Entities

**BorrowedItem** (in `entities/borrowed_item.dart`):

- Properties: `item` (LibraryItem), `borrowDate` (DateTime), `dueDate` (DateTime), `returnDate` (DateTime?), `isReturned` (bool)
- Methods:
  - `isOverdue()` - checks if past due date and not returned
  - `getDaysOverdue()` - calculates overdue days, returns 0 if not overdue
  - `calculateLateFee()` - computes fee based on overdue days
  - `extendDueDate(int additionalDays)` - extends due date if allowed
  - `processReturn()` - marks as returned with current timestamp

**Review** (in `entities/review.dart`):

- Properties: `rating` (int, 1-5), `comment` (String), `reviewerName` (String), `reviewDate` (DateTime), `itemId` (String)
- Methods:
  - `isValidRating()` - validates rating is between 1-5
  - `getWordCount()` - returns comment word count
  - `toJson()` and `fromJson()` for serialization

###### Services

**LibrarySystem** (in `services/library_system.dart`):

- Constructor accepts LibraryRepository and MemberRepository dependencies
- Complex business logic methods requiring multi-step thinking:
  - `borrowItem(String memberId, String itemId)` - validates member eligibility, item availability, borrowing limits; creates BorrowedItem; updates availability
  - `returnItem(String memberId, String itemId)` - processes return, calculates fees, updates availability, handles fee payment if needed
  - `generateOverdueReport()` - creates detailed report with member info, item details, overdue duration, calculated fees
  - `recommendItems(String memberId, int maxRecommendations)` - suggests items based on borrowing history and ratings
  - `processMonthlyReport()` - generates comprehensive statistics: popular items, active members, revenue from fees, trends analysis
  - `handleReservation(String memberId, String itemId)` - allows members to reserve unavailable items (queue system)

#### 5. Testing Requirements

Implement comprehensive `main()` function in `bin/digital_library.dart` that demonstrates:

##### Library Items Testing

- Load different item types from JSON arrays
- Search functionality with partial matches
- Category filtering and sorting
- Review system with multiple reviews per item
- Popularity scoring and similar items finding
- Collection health analysis

##### Members Testing

- Create different member types with specific limits
- Test borrowing eligibility validation
- Demonstrate member type polymorphism
- Fee calculation and payment processing

##### System Integration Testing

- Complete borrowing workflow with validation
- Return processing with fee calculation
- Overdue report generation
- Item recommendation system
- Monthly analytics report

##### Error Handling Testing

- Invalid member/item IDs
- Exceeded borrowing limits
- Attempting to borrow unavailable items
- Duplicate review prevention
- Invalid payment amountså

---

### Deliverables

1. Complete Dart source code following the specified feature-based Clean Architecture
2. `Assignment1-TestingDoc-Grading-Sheet.docx` with comprehensive screenshots showing all functionality
3. Push all work to your GitHub repository under `Assignments/Assignment1`

### Grading Criteria

- **Feature-Based Clean Architecture (25%)**: Proper feature separation, layer organization, dependency management
- **OOP Implementation (25%)**: Inheritance hierarchies, polymorphism, mixins, interfaces with proper encapsulation
- **Dart Features (25%)**: Complex extension methods, analytical functions, collection processing, null safety
- **Functionality (25%)**: System integration, business logic implementation, comprehensive testing, error handling

### Important Implementation Notes

- All extension methods must use functional programming approaches (no traditional loops)
- Implement proper validation in business logic methods
- Handle edge cases in analytical functions
- Use meaningful variable names and comprehensive documentation
- Demonstrate polymorphic behavior throughout the system
- Include proper error messages and exception handling
