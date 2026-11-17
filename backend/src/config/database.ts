import mongoose from 'mongoose';
import { ENV } from './env.js';
import { logger } from '../utils/logger.js';

let mongodInstance: any = null;

export const connectDatabase = async (): Promise<void> => {
  try {
    // Enable mongoose strict query
    mongoose.set('strictQuery', true);

    // Attempt connecting to configured MONGODB_URI with short timeout
    logger.db(`Connecting to MongoDB at: ${ENV.MONGODB_URI}...`);

    await mongoose.connect(ENV.MONGODB_URI, {
      serverSelectionTimeoutMS: 3000,
    });

    logger.success(`MongoDB Connected: ${mongoose.connection.host}/${mongoose.connection.name}`);
  } catch (error: any) {
    logger.warn(`Could not connect to external MongoDB: ${error.message}`);

    // If in development, automatically start embedded in-memory MongoDB
    if (!ENV.IS_PRODUCTION) {
      logger.info('Starting embedded in-memory MongoDB server for zero-setup local development...');
      try {
        const { MongoMemoryServer } = await import('mongodb-memory-server');
        mongodInstance = await MongoMemoryServer.create({
          instance: {
            dbName: 'service_booking',
          },
        });

        const uri = mongodInstance.getUri();
        await mongoose.connect(uri);
        logger.success(`Embedded MongoDB running at: ${uri}`);

        // Automatically seed demo data into the embedded database
        const { autoSeedIfEmpty } = await import('../scripts/seed.js');
        await autoSeedIfEmpty();
      } catch (innerErr: any) {
        logger.error(`Failed to start in-memory MongoDB: ${innerErr.message}`);
        throw innerErr;
      }
    } else {
      throw error;
    }
  }
};

export const disconnectDatabase = async (): Promise<void> => {
  try {
    await mongoose.disconnect();
    if (mongodInstance) {
      await mongodInstance.stop();
    }
    logger.info('Database disconnected cleanly.');
  } catch (err: any) {
    logger.error('Error disconnecting database:', err.message);
  }
};

