import { Router } from 'express';
import mongoose from 'mongoose';
import authRoutes from './auth.routes.js';
import userRoutes from './user.routes.js';
import serviceRoutes from './service.routes.js';
import appointmentRoutes from './appointment.routes.js';
import aiRoutes from './ai.routes.js';
import { ApiResponse } from '../utils/apiResponse.js';
import { ENV } from '../config/env.js';

const apiRouter = Router();

// Health check endpoint
apiRouter.get('/health', (req, res) => {
  const dbStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';
  const aiStatus = ENV.GEMINI_API_KEY ? 'gemini-active' : 'rule-engine-fallback';

  return ApiResponse.success(res, 'Service Booking API is running normally', {
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    database: dbStatus,
    aiProvider: aiStatus,
    version: '1.0.0',
  });
});

// Mount modules
apiRouter.use('/auth', authRoutes);
apiRouter.use('/users', userRoutes);
apiRouter.use('/services', serviceRoutes);
apiRouter.use('/appointments', appointmentRoutes);
apiRouter.use('/ai', aiRoutes);

export default apiRouter;
