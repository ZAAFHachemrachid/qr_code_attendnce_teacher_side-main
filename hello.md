Let's create a gRPC-based library system with users and books using Axum, PostgreSQL, and Rust. I'll break this down into parts, focusing on users and books first. We'll use `sqlx` for PostgreSQL integration.

Here's the initial setup:

### 1. Dependencies in `Cargo.toml`
```toml
[dependencies]
axum = "0.7"
tonic = "0.11"
prost = "0.12"
tokio = { version = "1.0", features = ["macros", "rt-multi-thread"] }
serde = { version = "1.0", features = ["derive"] }
sqlx = { version = "0.7", features = ["runtime-tokio-rustls", "postgres", "uuid", "time"] }
uuid = { version = "1.7", features = ["v4", "serde"] }
time = "0.3"
tower = "0.4"
```

### 2. Proto Definition (`proto/library.proto`)
```protobuf
syntax = "proto3";
package library;

service Library {
    // User operations
    rpc CreateUser (CreateUserRequest) returns (UserResponse);
    rpc GetUser (GetUserRequest) returns (UserResponse);
    
    // Book operations
    rpc CreateBook (CreateBookRequest) returns (BookResponse);
    rpc GetBook (GetBookRequest) returns (BookResponse);
}

message CreateUserRequest {
    string name = 1;
    string email = 2;
}

message GetUserRequest {
    string id = 1;
}

message UserResponse {
    string id = 1;
    string name = 2;
    string email = 3;
    string created_at = 4;
}

message CreateBookRequest {
    string title = 1;
    string author = 2;
    string isbn = 3;
}

message GetBookRequest {
    string id = 1;
}

message BookResponse {
    string id = 1;
    string title = 2;
    string author = 3;
    string isbn = 4;
    string created_at = 5;
}
```

### 3. Main Rust Code (`src/main.rs`)
```rust
use axum::{Router, routing::get};
use sqlx::{PgPool, Postgres, Pool};
use tonic::{transport::Server, Request, Response, Status};
use uuid::Uuid;
use time::OffsetDateTime;

// Generated from proto file
pub mod proto {
    tonic::include_proto!("library");
}

use proto::library_server::{Library, LibraryServer};

// Database models
#[derive(sqlx::FromRow)]
struct User {
    id: Uuid,
    name: String,
    email: String,
    created_at: OffsetDateTime,
}

#[derive(sqlx::FromRow)]
struct Book {
    id: Uuid,
    title: String,
    author: String,
    isbn: String,
    created_at: OffsetDateTime,
}

// Service state
#[derive(Clone)]
struct LibraryState {
    db: PgPool,
}

// Service implementation
struct LibraryService {
    state: LibraryState,
}

#[tonic::async_trait]
impl Library for LibraryService {
    // User operations
    async fn create_user(
        &self,
        request: Request<proto::CreateUserRequest>,
    ) -> Result<Response<proto::UserResponse>, Status> {
        let req = request.into_inner();
        let id = Uuid::new_v4();
        
        let user = sqlx::query_as::<_, User>(
            "INSERT INTO users (id, name, email) VALUES ($1, $2, $3) RETURNING *"
        )
        .bind(id)
        .bind(&req.name)
        .bind(&req.email)
        .fetch_one(&self.state.db)
        .await
        .map_err(|e| Status::internal(e.to_string()))?;

        Ok(Response::new(proto::UserResponse {
            id: user.id.to_string(),
            name: user.name,
            email: user.email,
            created_at: user.created_at.to_string(),
        }))
    }

    async fn get_user(
        &self,
        request: Request<proto::GetUserRequest>,
    ) -> Result<Response<proto::UserResponse>, Status> {
        let req = request.into_inner();
        let id = Uuid::parse_str(&req.id)
            .map_err(|e| Status::invalid_argument(e.to_string()))?;

        let user = sqlx::query_as::<_, User>("SELECT * FROM users WHERE id = $1")
            .bind(id)
            .fetch_one(&self.state.db)
            .await
            .map_err(|e| Status::not_found(e.to_string()))?;

        Ok(Response::new(proto::UserResponse {
            id: user.id.to_string(),
            name: user.name,
            email: user.email,
            created_at: user.created_at.to_string(),
        }))
    }

    // Book operations
    async fn create_book(
        &self,
        request: Request<proto::CreateBookRequest>,
    ) -> Result<Response<proto::BookResponse>, Status> {
        let req = request.into_inner();
        let id = Uuid::new_v4();

        let book = sqlx::query_as::<_, Book>(
            "INSERT INTO books (id, title, author, isbn) VALUES ($1, $2, $3, $4) RETURNING *"
        )
        .bind(id)
        .bind(&req.title)
        .bind(&req.author)
        .bind(&req.isbn)
        .fetch_one(&self.state.db)
        .await
        .map_err(|e| Status::internal(e.to_string()))?;

        Ok(Response::new(proto::BookResponse {
            id: book.id.to_string(),
            title: book.title,
            author: book.author,
            isbn: book.isbn,
            created_at: book.created_at.to_string(),
        }))
    }

    async fn get_book(
        &self,
        request: Request<proto::GetBookRequest>,
    ) -> Result<Response<proto::BookResponse>, Status> {
        let req = request.into_inner();
        let id = Uuid::parse_str(&req.id)
            .map_err(|e| Status::invalid_argument(e.to_string()))?;

        let book = sqlx::query_as::<_, Book>("SELECT * FROM books WHERE id = $1")
            .bind(id)
            .fetch_one(&self.state.db)
            .await
            .map_err(|e| Status::not_found(e.to_string()))?;

        Ok(Response::new(proto::BookResponse {
            id: book.id.to_string(),
            title: book.title,
            author: book.author,
            isbn: book.isbn,
            created_at: book.created_at.to_string(),
        }))
    }
}

// Health check endpoint
async fn health_check() -> &'static str {
    "OK"
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Database connection
    let database_url = "postgres://user:password@localhost/library";
    let db = PgPool::connect(database_url).await?;

    // Run migrations (create tables)
    sqlx::migrate!("./migrations").run(&db).await?;

    let state = LibraryState { db };
    let service = LibraryService { state };

    // Server address
    let addr = "[::1]:3000".parse()?;

    // Axum router for HTTP endpoints
    let app = Router::new()
        .route("/health", get(health_check));

    // gRPC server
    let grpc = Server::builder()
        .add_service(LibraryServer::new(service));

    println!("Server listening on {}", addr);

    // Combine HTTP and gRPC
    axum::Server::bind(&addr)
        .serve(
            app.into_make_service()
                .with_grpc(grpc)
        )
        .await?;

    Ok(())
}
```

### 4. Database Migrations (`migrations/20250406_create_tables.sql`)
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    name VARCHAR NOT NULL,
    email VARCHAR NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE books (
    id UUID PRIMARY KEY,
    title VARCHAR NOT NULL,
    author VARCHAR NOT NULL,
    isbn VARCHAR NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### Key Features:
1. **Database Integration**: Uses `sqlx` for type-safe PostgreSQL queries
2. **gRPC Service**: Implements basic CRUD operations for users and books
3. **HTTP Health Check**: Simple endpoint for monitoring
4. **State Management**: Uses a struct to hold the database connection pool
5. **Error Handling**: Basic error mapping to gRPC Status codes
6. **UUID**: Uses UUID v4 for unique identifiers

### To Run:
1. Set up PostgreSQL and update the connection string in `main()`
2. Create a `proto/` directory with the `.proto` file
3. Create a `migrations/` directory with the SQL file
4. Run `cargo build` to generate proto code (assuming proper build.rs setup)
5. Run `cargo run`

This is a foundation that you can extend with:
- More operations (update, delete, list)
- Book borrowing system
- Authentication
- Validation
- Better error handling
- Connection pooling configuration

Would you like me to expand on any specific part of this system?