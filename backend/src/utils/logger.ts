const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

const timestamp = (): string => new Date().toISOString();

export const logger = {
  info: (msg: string, ...args: any[]) => {
    console.log(`${colors.cyan}[${timestamp()}] [INFO]${colors.reset} ${msg}`, ...args);
  },
  success: (msg: string, ...args: any[]) => {
    console.log(`${colors.green}[${timestamp()}] [SUCCESS]${colors.reset} ${msg}`, ...args);
  },
  warn: (msg: string, ...args: any[]) => {
    console.warn(`${colors.yellow}[${timestamp()}] [WARN]${colors.reset} ${msg}`, ...args);
  },
  error: (msg: string, ...args: any[]) => {
    console.error(`${colors.red}[${timestamp()}] [ERROR]${colors.reset} ${msg}`, ...args);
  },
  db: (msg: string, ...args: any[]) => {
    console.log(`${colors.magenta}[${timestamp()}] [DATABASE]${colors.reset} ${msg}`, ...args);
  },
  ai: (msg: string, ...args: any[]) => {
    console.log(`${colors.blue}[${timestamp()}] [AI-ASSISTANT]${colors.reset} ${msg}`, ...args);
  },
};
