import http from 'http';
import { createApp } from './app.js';
import { connectDatabase, disconnectDatabase } from './config/database.js';
import { ENV } from './config/env.js';
import { logger } from './utils/logger.js';

const startServer = async () => {
  try {
    // 1. Connect to Database (auto fallback to memory server if local MongoDB is offline)
    await connectDatabase();

    // 2. Initialize Express application
    const app = createApp();
    const server = http.createServer(app);

    // 3. Start listening on configured port (bind to 0.0.0.0 to allow LAN & physical devices)
    server.listen(ENV.PORT, '0.0.0.0', () => {
      logger.success(`🚀 Server running in ${ENV.NODE_ENV} mode on port ${ENV.PORT}`);
      logger.info(`📖 Swagger UI Documentation: http://localhost:${ENV.PORT}/api/docs`);
      logger.info(`🔍 Health Check: http://localhost:${ENV.PORT}/api/health`);
      logger.info(`📱 For Android Emulator use: http://10.0.2.2:${ENV.PORT}/api`);
    });

    // 4. Graceful shutdown handler
    const gracefulShutdown = async (signal: string) => {
      logger.info(`Received ${signal}. Shutting down gracefully...`);
      server.close(async () => {
        logger.info('HTTP server closed.');
        await disconnectDatabase();
        process.exit(0);
      });

      // Force shutdown if taking too long
      setTimeout(() => {
        logger.error('Forced shutdown due to timeout');
        process.exit(1);
      }, 10000);
    };

    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));
  } catch (error: any) {
    logger.error('Failed to start server:', error.message);
    process.exit(1);
  }
};

startServer();

