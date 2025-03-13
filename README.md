# Blockchain-Based Event Ticketing System

A decentralized solution for secure, transparent, and fair event ticketing powered by blockchain technology.

## Overview

This system leverages blockchain technology to revolutionize event ticketing by eliminating counterfeiting, controlling secondary market pricing, increasing transparency, and streamlining the attendee experience. Our solution provides event organizers with powerful tools to manage their events while giving attendees confidence in ticket authenticity and fair pricing.

## Core Components

### Event Creation Contract

Establishes the digital foundation for events and seating inventory:
- Event details (name, date, time, venue, description)
- Seating categories and capacity management
- Pricing tiers and dynamic pricing rules
- Event-specific terms and conditions
- Organizer verification and digital signature
- Revenue distribution rules for multiple stakeholders
- Event cancellation and refund policies

### Ticket Issuance Contract

Creates and manages verifiable digital tickets:
- Unique non-fungible tokens (NFTs) for each ticket
- Batch issuance capabilities for efficiency
- Ticket metadata and visual assets
- Customizable ticket attributes (VIP access, merchandise, etc.)
- Integration with fiat payment gateways
- Tax and fee calculations
- Purchase receipt generation

### Transfer Control Contract

Regulates the secondary market to prevent scalping:
- Configurable resale permissions
- Price ceiling enforcement
- Royalty distribution on secondary sales
- Waiting list management for high-demand events
- Time-based transfer restrictions
- Buyer verification requirements
- Fraud prevention mechanisms

### Attendance Verification Contract

Validates tickets at event entry:
- QR code generation and scanning
- Mobile wallet integration
- Offline verification capabilities
- Multi-device synchronization
- Entry/exit tracking for re-entry
- Attendance analytics and reporting
- Integration with venue access control systems

## Getting Started

### Prerequisites

- Node.js (v16.0+)
- Truffle or Hardhat development framework
- Web3 wallet (MetaMask, etc.)
- IPFS (for storing ticket metadata and images)
- Mobile device for testing QR code scanning

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/blockchain-ticketing.git
cd blockchain-ticketing

# Install dependencies
npm install

# Compile smart contracts
npx truffle compile
# or
npx hardhat compile
```

### Deployment

```bash
# Deploy to testnet
npx truffle migrate --network goerli
# or
npx hardhat run scripts/deploy.js --network goerli

# Deploy to mainnet
npx truffle migrate --network mainnet
# or
npx hardhat run scripts/deploy.js --network mainnet
```

## Usage Examples

### For Event Organizers

```javascript
// Create a new event
await eventCreationContract.createEvent(
  "Summer Music Festival 2025",
  1719792000, // July 31, 2025 UTC timestamp
  "Central Park, New York",
  "ipfs://QmXgbTyCRSzXKGbEJUg4SX8soWgFSQRVJKobjxpo8Kdj8j", // Event details & image
  totalCapacity,
  { from: organizerAddress }
);

// Set up ticket tiers
await eventCreationContract.addTicketTier(
  eventId,
  "VIP",
  500,
  ethers.utils.parseEther("0.5"), // 0.5 ETH
  200, // 200 tickets available
  { from: organizerAddress }
);

// Issue tickets (batch operation)
await ticketIssuanceContract.batchIssueTickets(
  eventId,
  "General Admission",
  1000, // Quantity
  { from: organizerAddress }
);
```

### For Ticket Purchasers

```javascript
// Purchase a ticket
await ticketIssuanceContract.purchaseTicket(
  eventId,
  "General Admission",
  { from: purchaserAddress, value: ticketPrice }
);

// View purchased tickets
const myTickets = await ticketIssuanceContract.getTicketsByOwner(
  { from: purchaserAddress }
);
```

### For Ticket Resellers

```javascript
// List ticket for resale
await transferControlContract.listTicketForResale(
  ticketId,
  resalePrice, // Must be below max allowed price
  { from: currentTicketOwner }
);

// Purchase resale ticket
await transferControlContract.purchaseResaleTicket(
  ticketId,
  { from: newOwnerAddress, value: resalePrice }
);
```

### For Event Staff

```javascript
// Verify ticket at entry
await attendanceVerificationContract.verifyTicket(
  ticketId,
  scannerSignature,
  timestamp,
  { from: authorizedStaffAddress }
);

// Generate event attendance report
const attendanceStats = await attendanceVerificationContract.getEventAttendanceStats(
  eventId,
  { from: organizerAddress }
);
```

## System Architecture

The system architecture consists of four primary smart contracts that interact with each other:

1. **EventCreation**: Central contract that initializes events and manages seating inventory
2. **TicketIssuance**: Creates NFT tickets and handles the primary market sales
3. **TransferControl**: Manages the secondary market with price controls
4. **AttendanceVerification**: Handles ticket validation at the venue

The system leverages:
- ERC-721 standard for unique ticket NFTs
- IPFS for decentralized storage of metadata and images
- Layer 2 scaling solutions for reduced gas fees and faster transactions
- Chainlink oracles for fiat currency price feeds
- Zero-knowledge proofs for privacy-preserving identity verification

## Frontend Applications

### Mobile App for Attendees

Features:
- Digital ticket wallet
- Event discovery and purchases
- QR code generation for entry
- Transfer tickets to friends
- Offline ticket backup
- Event notifications and updates
- In-app messaging with organizers

### Dashboard for Organizers

Features:
- Event creation and management
- Real-time sales analytics
- Attendee communication tools
- Dynamic pricing controls
- Entry flow monitoring
- Revenue distribution tracking
- Attendee demographics and insights

## Key Benefits

- **Eliminate Counterfeiting**: Each ticket is a unique, verifiable NFT
- **Control Resale Prices**: Prevent scalping with price ceilings
- **Increase Transparency**: All transactions are visible on the blockchain
- **Automate Royalties**: Organizers receive a percentage of secondary sales
- **Reduce Fees**: Lower transaction costs compared to traditional ticketing
- **Enhance User Experience**: Seamless purchasing and entry verification
- **Provide Analytics**: Rich data on sales and attendance patterns

## Roadmap

- **Phase 1**: Core smart contract development and testing
- **Phase 2**: Mobile app and organizer dashboard development
- **Phase 3**: Integration with major payment gateways
- **Phase 4**: Advanced features (dynamic pricing, subscription passes)
- **Phase 5**: Enterprise partnerships and white-label solutions
- **Phase 6**: Cross-chain compatibility and interoperability

## Security Considerations

- Multisignature requirements for critical operations
- Rate limiting to prevent flash attacks
- Secure ticket validation algorithms
- Regular security audits of smart contracts
- Privacy-preserving attendee data handling
- Tamper-proof QR code generation

## Legal Considerations

This system is designed to comply with:
- Consumer protection regulations
- Data privacy laws (GDPR, CCPA)
- Tax reporting requirements
- Refund and cancellation policies
- Accessibility standards
- Terms of service enforcement

## Contributing

We welcome contributions from blockchain developers, event management professionals, and security experts. Please read our contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions, support, or partnership inquiries, please contact the development team at dev@blockchainticketing.com
