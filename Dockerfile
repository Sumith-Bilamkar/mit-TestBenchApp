# ---- Build Stage ----
FROM golang:1.24.1-alpine AS builder

WORKDIR /app

# Copy only go.mod (since go.sum is absent)
COPY go.mod ./

# Download dependencies (will be skipped if there are none)
RUN go mod download || true

# Copy the application code
COPY . .

# Build the Go application
RUN go build -o main .

# ---- Run Stage ----
FROM alpine:latest

WORKDIR /root/

# Copy the compiled binary
COPY --from=builder /app/main .

# Expose port
EXPOSE 8085

# Run the application
CMD ["./main"]