# {{PROJECT_NAME}} - Claude Code Configuration

This file defines the architectural standards, development policies, and AI assistance guidelines for the {{PROJECT_NAME}} project.

## 🏗️ Architecture Standards

### Backend Architecture (.NET)
**MANDATORY**: All backend development must follow these patterns:

#### N-Tier Architecture
- **Presentation Layer**: Web API controllers (minimal, routing only)
- **Business Logic Layer**: Domain services, business rules, validation
- **Data Access Layer**: Repository pattern, Entity Framework Core
- **Data Layer**: Supabase PostgreSQL database

#### Domain-Driven Design (DDD)
- **Entities**: Rich domain models with behavior and business rules
- **Value Objects**: Immutable objects defined by their attributes
- **Aggregates**: Consistency boundaries with aggregate roots
- **Domain Services**: Stateless operations that don't belong to entities
- **Repositories**: Abstract data access with interface-based contracts
- **Domain Events**: Communicate changes within bounded contexts

#### Repository Pattern (MANDATORY)
```csharp
// ✅ CORRECT: Interface-based repository
public interface IUserRepository
{
    Task<User> GetByIdAsync(Guid id);
    Task<IEnumerable<User>> GetAllAsync();
    Task<User> AddAsync(User user);
    Task UpdateAsync(User user);
    Task DeleteAsync(Guid id);
}

// ❌ WRONG: Direct database access in controllers
public class UserController : ControllerBase
{
    public async Task<User> GetUser(Guid id)
    {
        // Direct EF context usage - PROHIBITED
        return await _context.Users.FindAsync(id);
    }
}
```

#### Service Layer Pattern
- **Application Services**: Orchestrate domain operations, handle cross-cutting concerns
- **Domain Services**: Pure business logic without infrastructure dependencies
- **Infrastructure Services**: External integrations (email, payment, etc.)

### Frontend Architecture (React 19+)
**MANDATORY**: All frontend development must follow these patterns:

#### Atomic Component Design (MANDATORY)
- **Atoms**: Basic HTML elements (buttons, inputs, labels, icons)
- **Molecules**: Simple combinations of atoms (search box, form field)
- **Organisms**: Complex UI components (header, product grid, form sections)
- **Templates**: Page layouts without real content
- **Pages**: Templates filled with real content and data

```tsx
// ✅ CORRECT: Atomic structure
// Atom
export const Button = ({ children, onClick, variant = 'primary' }) => (
  <button className={`btn btn-${variant}`} onClick={onClick}>
    {children}
  </button>
);

// Molecule
export const SearchBox = ({ onSearch, placeholder }) => (
  <div className="search-box">
    <Input placeholder={placeholder} />
    <Button onClick={onSearch}>Search</Button>
  </div>
);

// ❌ WRONG: Monolithic components
export const MegaFormComponent = () => {
  // 500+ lines of mixed concerns - PROHIBITED
};
```

#### API Communication Policy (MANDATORY)
**CRITICAL**: Frontend MUST NEVER access database directly. All data access through backend APIs only.

```tsx
// ✅ CORRECT: API-only data access
const UserService = {
  getUser: (id: string) => fetch(`/api/users/${id}`).then(r => r.json()),
  updateUser: (user: User) => fetch('/api/users', { 
    method: 'PUT', 
    body: JSON.stringify(user) 
  })
};

// ❌ WRONG: Direct database access - STRICTLY PROHIBITED
import { createClient } from '@supabase/supabase-js';
const supabase = createClient(url, key); // NEVER DO THIS IN FRONTEND
```

#### State Management
- **Local State**: React hooks (useState, useReducer) for component-level state
- **Global State**: Context API or Zustand for app-wide state
- **Server State**: React Query/TanStack Query for API data caching
- **Form State**: React Hook Form for complex forms

### Database Architecture (Supabase)
**MANDATORY**: All database operations follow these standards:

#### Database Design Patterns
- **Row Level Security (RLS)**: MANDATORY for all tables
- **Normalized Schema**: Follow 3NF minimum, BCNF preferred
- **Audit Trails**: created_at, updated_at, created_by, updated_by on all tables
- **Soft Deletes**: Use deleted_at columns, never hard delete user data

#### Connection Management
```csharp
// ✅ CORRECT: Repository pattern with connection management
public class UserRepository : IUserRepository
{
    private readonly IDbContext _context;
    
    public async Task<User> GetByIdAsync(Guid id)
    {
        return await _context.Users
            .Where(u => u.Id == id && u.DeletedAt == null)
            .FirstOrDefaultAsync();
    }
}

// ❌ WRONG: Direct connection in business logic
public class UserService
{
    public async Task<User> GetUser(Guid id)
    {
        using var connection = new NpgsqlConnection(connectionString); // PROHIBITED
        // Direct SQL in business layer - WRONG
    }
}
```

### Message Bus Architecture (SAGA Pattern)
**MANDATORY**: All distributed transactions use message bus patterns:

#### Service Bus Implementation
- **Message Topics**: Domain-specific topics (user.events, order.events, payment.events)
- **Event Sourcing**: Store all domain events for audit and replay
- **Saga Orchestration**: Central coordinator for complex business processes
- **Dead Letter Queues**: Handle failed message processing

```csharp
// ✅ CORRECT: SAGA with message bus
public class OrderSaga : ISaga<OrderCreatedEvent>
{
    public async Task Handle(OrderCreatedEvent @event, ISagaContext context)
    {
        // Publish to service bus topic
        await context.Publish("payment.commands", new ProcessPaymentCommand
        {
            OrderId = @event.OrderId,
            Amount = @event.Amount
        });
    }
}

// ❌ WRONG: Direct service calls in distributed transactions
public class OrderService
{
    public async Task ProcessOrder(Order order)
    {
        // Direct HTTP calls - PROHIBITED in SAGA patterns
        await _paymentService.ProcessPayment(order.Amount);
        await _inventoryService.ReserveItems(order.Items);
    }
}
```

## 🎯 Naming Conventions

### C# Backend Naming
- **Classes**: PascalCase (`UserService`, `OrderRepository`)
- **Methods**: PascalCase (`GetUserByIdAsync`, `ProcessPayment`)
- **Properties**: PascalCase (`FirstName`, `CreatedAt`)
- **Fields**: camelCase with underscore (`_logger`, `_repository`)
- **Constants**: PascalCase (`MaxRetryCount`, `DefaultTimeout`)
- **Interfaces**: IPascalCase (`IUserService`, `IRepository<T>`)

### TypeScript Frontend Naming
- **Components**: PascalCase (`UserCard`, `NavigationMenu`)
- **Files**: PascalCase for components (`UserCard.tsx`), camelCase for utilities (`userService.ts`)
- **Variables**: camelCase (`userName`, `isLoading`)
- **Constants**: UPPER_SNAKE_CASE (`API_BASE_URL`, `MAX_FILE_SIZE`)
- **Types**: PascalCase (`User`, `ApiResponse<T>`)
- **Hooks**: camelCase starting with 'use' (`useUser`, `useApi`)

### Database Naming
- **Tables**: snake_case plural (`users`, `order_items`)
- **Columns**: snake_case (`first_name`, `created_at`)
- **Primary Keys**: `id` (UUID type)
- **Foreign Keys**: `{table}_id` (`user_id`, `order_id`)
- **Indexes**: `idx_{table}_{column(s)}` (`idx_users_email`)
- **Constraints**: `{type}_{table}_{column}` (`ck_users_email_format`)

### API Naming
- **Endpoints**: REST conventions with plural nouns
  - GET `/api/users` (list)
  - GET `/api/users/{id}` (single)
  - POST `/api/users` (create)
  - PUT `/api/users/{id}` (update)
  - DELETE `/api/users/{id}` (delete)
- **Query Parameters**: camelCase (`?pageSize=10&sortBy=createdAt`)
- **Request/Response Models**: PascalCase (`CreateUserRequest`, `UserResponse`)

## 🔄 CI/CD Policy

### Quality Gates (MANDATORY)
All code changes must pass these gates before merge:

#### 1. Structure Validation
- Repository structure follows N-tier architecture
- Atomic component organization verified
- Naming conventions enforced
- No direct database access in frontend

#### 2. Security Validation
- OWASP Top 10 compliance
- Dependency vulnerability scanning
- Secrets detection
- SQL injection prevention

#### 3. Testing Requirements
- **Unit Tests**: 70%+ code coverage
- **Integration Tests**: All API endpoints tested
- **E2E Tests**: Critical user journeys validated
- **Component Tests**: All React components tested

#### 4. Performance Standards
- **API Response Time**: <500ms P95
- **Frontend Bundle Size**: <1MB initial load
- **Database Query Performance**: <100ms average
- **Core Web Vitals**: LCP <2.5s, FID <100ms, CLS <0.1

#### 5. Accessibility Compliance
- WCAG 2.2 Level AA compliance
- Screen reader compatibility
- Keyboard navigation support
- Color contrast validation

### Branch Strategy
- **main**: Production-ready code only
- **develop**: Integration branch for feature development
- **feature/***: Feature development branches
- **hotfix/***: Emergency production fixes

### Deployment Pipeline
```yaml
# Deployment stages (MANDATORY)
stages:
  - validate-structure
  - security-scan
  - unit-tests
  - integration-tests
  - build
  - e2e-tests
  - performance-tests
  - accessibility-tests
  - deploy-staging
  - smoke-tests
  - deploy-production
```

## 📐 Architecture Enforcement Rules

### Code Review Requirements
**MANDATORY CHECKS** for all pull requests:

#### Backend (.NET) Checklist
- [ ] Repository pattern implemented correctly
- [ ] No direct EF Context usage in controllers
- [ ] Domain-driven design patterns followed
- [ ] Service layer properly separated
- [ ] Database connections managed through DI
- [ ] No business logic in controllers
- [ ] Async/await used for database operations
- [ ] Exception handling implemented
- [ ] Unit tests for business logic

#### Frontend (React) Checklist
- [ ] Atomic component design followed
- [ ] No direct database access (Supabase client usage)
- [ ] API-only data fetching implemented
- [ ] Component separation (atoms/molecules/organisms)
- [ ] State management appropriate for scope
- [ ] TypeScript strict mode compliance
- [ ] Accessibility features implemented
- [ ] Performance optimizations applied

#### Database (Supabase) Checklist
- [ ] Row Level Security (RLS) enabled on all tables
- [ ] Proper foreign key relationships
- [ ] Audit fields present (created_at, updated_at, etc.)
- [ ] Soft delete pattern implemented
- [ ] Database migrations versioned
- [ ] Indexes optimized for query patterns

#### Message Bus (SAGA) Checklist
- [ ] Service bus topics properly defined
- [ ] Message contracts versioned
- [ ] Dead letter queue handling
- [ ] Saga state management implemented
- [ ] Event sourcing for audit trails
- [ ] Message durability configured

## 🚫 Prohibited Patterns

### NEVER DO THESE:
```csharp
// ❌ Direct database access in controllers
public class UserController : ControllerBase
{
    private readonly DbContext _context; // PROHIBITED
}

// ❌ Business logic in controllers
public async Task<IActionResult> CreateUser(CreateUserRequest request)
{
    // Complex validation logic here - WRONG LAYER
    if (request.Email.Contains("@spam.com")) return BadRequest();
    // Should be in domain service
}
```

```tsx
// ❌ Direct database access in React
import { createClient } from '@supabase/supabase-js';
const supabase = createClient(url, key); // STRICTLY PROHIBITED

// ❌ Monolithic components
const MegaComponent = () => {
  // 500+ lines mixing atoms, molecules, and organisms - WRONG
};

// ❌ Direct API calls in components
const UserProfile = () => {
  useEffect(() => {
    fetch('/api/users/1').then(/* ... */); // Should use service layer
  }, []);
};
```

## 🎯 Claude Code Instructions

When working on this project, Claude must:

### 1. Architecture Enforcement
- Always validate code against N-tier architecture
- Enforce repository pattern in backend
- Ensure atomic component design in frontend
- Prevent direct database access from frontend

### 2. Code Quality Standards
- Run all quality gates before suggesting code completion
- Verify naming conventions compliance
- Ensure proper separation of concerns
- Validate API-first communication patterns

### 3. Testing Requirements
- Generate unit tests for all business logic
- Create integration tests for API endpoints
- Implement component tests for React components
- Ensure E2E test coverage for critical paths

### 4. Performance Considerations
- Optimize database queries through repository layer
- Implement proper React optimization (useMemo, useCallback)
- Bundle size analysis for frontend changes
- API response time monitoring

### 5. Security Validation
- Scan for OWASP Top 10 vulnerabilities
- Verify input validation and sanitization
- Ensure proper authentication and authorization
- Check for secrets exposure

## 📚 Documentation Requirements

### Code Documentation
- XML documentation for all public C# APIs
- JSDoc comments for all TypeScript functions
- README files for each major component
- Architecture decision records (ADRs)

### API Documentation
- OpenAPI/Swagger specifications
- Request/response examples
- Error code documentation
- Rate limiting information

### Database Documentation
- Entity relationship diagrams
- Table schema definitions
- Migration scripts documentation
- Performance tuning guidelines

## 🔧 Development Tools Integration

### Required Extensions/Tools
- **Backend**: SonarLint, ReSharper/Rider analyzers
- **Frontend**: ESLint, Prettier, React Developer Tools
- **Database**: Supabase CLI, database migration tools
- **Testing**: xUnit, Jest, Playwright
- **CI/CD**: GitHub Actions with quality gates

### IDE Configuration
- EditorConfig for consistent formatting
- Workspace settings for naming conventions
- Code analysis rules enforcement
- Automated testing on save

---

**Remember**: This architecture is MANDATORY for {{PROJECT_NAME}}. Any deviations must be approved through architecture review process and documented as ADRs.

**AI Assistant Compliance**: Claude Code must enforce these standards in all code suggestions, reviews, and implementations.