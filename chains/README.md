# ChainLens 

**The premier analytics dashboard for the Stacks ecosystem**

ChainLens provides comprehensive on-chain analytics, protocol metrics, and user insights for the Stacks blockchain. Built with Clarity smart contracts and modern web technologies.

##  Features

- **Protocol Analytics**: Track TVL, volume, and user metrics across Stacks DeFi protocols
- **Daily Statistics**: Historical data on transactions, volume, and network activity  
- **User Analytics**: Individual user behavior and interaction patterns
- **Real-time Data**: Live updates from the Stacks blockchain
- **Custom Dashboards**: Configurable views for different use cases
- **API Access**: RESTful endpoints for developers and integrations

##  Tech Stack

- **Smart Contracts**: Clarity on Stacks blockchain
- **Backend**: Node.js/Express API server
- **Frontend**: React with TypeScript
- **Database**: PostgreSQL for off-chain indexing
- **Styling**: Tailwind CSS
- **Charts**: Recharts for data visualization

##  Project Structure

```
chainlens/
├── contracts/
│   ├── chainlens.clar          # Main analytics contract
│   └── tests/
├── api/
│   ├── src/
│   ├── package.json
│   └── README.md
├── frontend/
│   ├── src/
│   ├── public/
│   └── package.json
├── Clarinet.toml
└── README.md
```

##  Development Setup

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) for smart contract development
- Node.js 18+ 
- PostgreSQL
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/sharon177/ChainLens.git
   cd chainlens
   ```

2. **Install Clarinet** (if not already installed)
   ```bash
   curl -L https://github.com/hirosystems/clarinet/releases/latest/download/clarinet-linux-x64-glibc.tar.gz | tar xz
   sudo mv clarinet /usr/local/bin
   ```

3. **Initialize the project**
   ```bash
   clarinet new chainlens
   cd chainlens
   ```

4. **Install dependencies**
   ```bash
   # API dependencies
   cd api && npm install
   
   # Frontend dependencies  
   cd ../frontend && npm install
   ```

### Smart Contract Development

1. **Test the contracts**
   ```bash
   clarinet test
   ```

2. **Deploy to local devnet**
   ```bash
   clarinet integrate
   ```

3. **Check contract syntax**
   ```bash
   clarinet check
   ```

### Running the Application

1. **Start the API server**
   ```bash
   cd api
   npm run dev
   ```

2. **Start the frontend** (in a new terminal)
   ```bash
   cd frontend  
   npm run dev
   ```

3. **Access the dashboard**
   Open `http://localhost:3000` in your browser

##  Smart Contract Functions

### Admin Functions
- `add-protocol`: Register a new protocol for tracking
- `update-protocol-metrics`: Update TVL, volume, and user data
- `record-daily-stats`: Store daily network statistics

### Public Functions  
- `submit-transaction-data`: Submit transaction data from external sources

### Read-Only Functions
- `get-protocol-metrics`: Retrieve protocol analytics
- `get-daily-stats`: Get historical daily data
- `get-user-analytics`: Fetch user behavior data
- `get-total-protocols`: Get count of tracked protocols

##  Configuration

### Environment Variables

Create a `.env` file in the root directory:

```bash
# API Configuration
PORT=3001
DATABASE_URL=postgresql://username:password@localhost:5432/chainlens
STACKS_API_URL=https://stacks-node-api.mainnet.stacks.co

# Contract Configuration  
CONTRACT_ADDRESS=ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
CONTRACT_NAME=chainlens

# Frontend Configuration
REACT_APP_API_URL=http://localhost:3001
REACT_APP_STACKS_NETWORK=mainnet
```

### Database Setup

```sql
-- Create database
CREATE DATABASE chainlens;

-- Run migrations (handled by API on startup)

##  API Endpoints

### Analytics
- `GET /api/protocols` - List all tracked protocols
- `GET /api/protocols/:id/metrics` - Get protocol metrics
- `GET /api/stats/daily?date=YYYY-MM-DD` - Daily statistics
- `GET /api/users/:address/analytics` - User analytics

### Data Submission
- `POST /api/submit/transaction` - Submit new transaction data
- `POST /api/submit/protocol-update` - Update protocol metrics