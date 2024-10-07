# Makefile for Building and Installing Screenpipe on MacOS

# Variables
PROJECT_DIR := $(shell pwd)
DESKTOP_APP_DIR := screenpipe-app-tauri
VSCODE_SETTINGS := .vscode/settings.json

# Signing Variables
SIGNING_DIR := $(PROJECT_DIR)/$(DESKTOP_APP_DIR)
PRIVATE_KEY_PATH := $(SIGNING_DIR)/tauri_signing_private_key.pem
BASE64_KEY_PATH := $(SIGNING_DIR)/tauri_signing_private_key_base64.txt
ENV_VAR_NAME := TAURI_SIGNING_PRIVATE_KEY

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: all install-deps install-rust check-brew build-cli build-desktop setup-signing generate-private-key encode-key configure-vscode run clean help

all: install-deps build-cli setup-signing build-desktop
	@echo "$(GREEN)All tasks completed successfully!$(NC)"

# Install Homebrew dependencies
install-deps: check-brew install-rust
	@echo "$(YELLOW)Installing Homebrew dependencies...$(NC)"
	brew install pkg-config ffmpeg jq tesseract cmake wget || echo "Some dependencies may already be installed."
	# Check if openssl is installed
	@which openssl > /dev/null 2>&1
	@if [ $$? -ne 0 ]; then \
		echo "$(YELLOW)openssl not found. Installing openssl...$(NC)"; \
		brew install openssl; \
	else \
		echo "$(GREEN)openssl is already installed.$(NC)"; \
	fi

# Check if Homebrew is installed
check-brew:
	@which brew > /dev/null 2>&1
	@if [ $$? -ne 0 ]; then \
		echo "$(RED)Homebrew is not installed. Please install Homebrew from https://brew.sh/ and rerun Makefile.$(NC)"; \
		exit 1; \
	fi

# Install Rust using rustup if not installed
install-rust:
	@echo "$(YELLOW)Checking for Rust installation...$(NC)"
	@which rustc > /dev/null 2>&1
	@if [ $$? -ne 0 ]; then \
		echo "$(YELLOW)Rust not found. Installing Rust using rustup...$(NC)"; \
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; \
		export PATH=$$HOME/.cargo/bin:$$PATH; \
	else \
		echo "$(GREEN)Rust is already installed.$(NC)"; \
	fi

# Build the CLI
build-cli:
	@echo "$(YELLOW)Building the Screenpipe CLI...$(NC)"
	cargo build --release --features metal
	@echo "$(GREEN)CLI built successfully.$(NC)"

# Setup Signing (Generate and Encode Private Key)
setup-signing: generate-private-key encode-key

# Generate Private Key if it does not exist
generate-private-key:
	@echo "$(YELLOW)Checking for private key...$(NC)"
	@if [ -f "$(PRIVATE_KEY_PATH)" ]; then \
		echo "$(GREEN)Private key already exists at $(PRIVATE_KEY_PATH).$(NC)"; \
	else \
		echo "$(YELLOW)Private key not found. Generating new private key...$(NC)"; \
		mkdir -p $(SIGNING_DIR); \
		openssl genpkey -algorithm RSA -out "$(PRIVATE_KEY_PATH)" -pkeyopt rsa_keygen_bits:2048; \
		if [ $$? -ne 0 ]; then \
			echo "$(RED)Failed to generate private key.$(NC)"; \
			exit 1; \
		else \
			echo "$(GREEN)Private key generated at $(PRIVATE_KEY_PATH).$(NC)"; \
		fi \
	fi

# Encode Private Key to Base64 (if required)
encode-key:
	@echo "$(YELLOW)Encoding private key to Base64...$(NC)"
	openssl base64 -in "$(PRIVATE_KEY_PATH)" -out "$(BASE64_KEY_PATH)"
	if [ $$? -ne 0 ]; then \
		echo "$(RED)Failed to encode private key to Base64.$(NC)"; \
		exit 1; \
	else \
		echo "$(GREEN)Base64 key saved at $(BASE64_KEY_PATH).$(NC)"; \
	fi

# Configure VSCode settings
configure-vscode:
	@echo "$(YELLOW)Configuring VSCode settings...$(NC)"
	@mkdir -p .vscode
	@echo '{\n\
		"rust-analyzer.cargo.features": [\n\
			"metal",\n\
			"pipes"\n\
		],\n\
		"rust-analyzer.server.extraEnv": {\n\
			"DYLD_LIBRARY_PATH": "$${workspaceFolder}/screenpipe-vision/lib:$${env:DYLD_LIBRARY_PATH}",\n\
			"SCREENPIPE_APP_DEV": "true"\n\
		},\n\
		"rust-analyzer.cargo.extraEnv": {\n\
			"DYLD_LIBRARY_PATH": "$${workspaceFolder}/screenpipe-vision/lib:$${env:DYLD_LIBRARY_PATH}",\n\
			"SCREENPIPE_APP_DEV": "true"\n\
		},\n\
		"terminal.integrated.env.osx": {\n\
			"DYLD_LIBRARY_PATH": "$${workspaceFolder}/screenpipe-vision/lib:$${env:DYLD_LIBRARY_PATH}",\n\
			"SCREENPIPE_APP_DEV": "true"\n\
		}\n\
}' > $(VSCODE_SETTINGS)
	@echo "$(GREEN)VSCode settings configured.$(NC)"

# Build the desktop application
build-desktop: setup-signing configure-vscode
	@echo "$(YELLOW)Building the Desktop Application...$(NC)"
	# Export the environment variable and build
	cd $(DESKTOP_APP_DIR) && \
	export $(ENV_VAR_NAME)=$$(cat "$(BASE64_KEY_PATH)") && \
	bun install && \
	bun scripts/pre_build.js && \
	bun tauri build
	@echo "$(GREEN)Desktop application built successfully.$(NC)"

# Run the CLI
run:
	@echo "$(YELLOW)Running the Screenpipe CLI...$(NC)"
	./target/release/screenpipe

# Clean build artifacts
clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	cargo clean
	@echo "$(GREEN)Cleaned successfully.$(NC)"

# Display help
help:
	@echo "Available Makefile targets:"
	@echo "  all             - Install dependencies, build CLI, setup signing, and build Desktop App"
	@echo "  install-deps    - Install Homebrew dependencies"
	@echo "  install-rust    - Install Rust using rustup"
	@echo "  build-cli       - Build the Screenpipe CLI"
	@echo "  setup-signing   - Setup signing keys for Tauri"
	@echo "  generate-private-key - Generate a new private key if it doesn't exist"
	@echo "  encode-key      - Encode the private key to Base64"
	@echo "  configure-vscode - Configure VSCode settings"
	@echo "  build-desktop   - Build the Desktop Application"
	@echo "  run             - Run the Screenpipe CLI"
	@echo "  clean           - Clean build artifacts"
	@echo "  help            - Show this help message"