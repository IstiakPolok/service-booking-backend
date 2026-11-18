import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import swaggerUi from 'swagger-ui-express';
import { readFileSync, existsSync } from 'fs';
import { fileURLToPath } from 'url';
import path from 'path';

import { ENV } from './config/env.js';
import apiRouter from './routes/index.js';
import { errorHandler, notFoundHandler } from './middlewares/error.middleware.js';
import { apiRateLimiter } from './middlewares/rateLimiter.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const createApp = (): Application => {
  const app = express();

  // Trust proxy for reverse proxies (Render, Heroku, Cloudflare, Nginx)
  app.set('trust proxy', 1);

  // Security Middleware
  app.use(
    helmet({
      contentSecurityPolicy: false, // Allows Swagger UI to render assets properly
    })
  );

  // CORS Middleware - Configured to support Flutter mobile, web, and emulator (10.0.2.2)
  app.use(
    cors({
      origin: ENV.CORS_ORIGIN === '*' ? true : ENV.CORS_ORIGIN,
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    })
  );

  // Body Parsing Middlewares
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // HTTP Request Logging
  if (ENV.NODE_ENV !== 'test') {
    app.use(morgan(ENV.IS_PRODUCTION ? 'combined' : 'dev'));
  }

  // Rate Limiting
  app.use('/api', apiRateLimiter);

  // Swagger Documentation Setup
  try {
    const possiblePaths = [
      path.join(__dirname, 'swagger', 'swagger.json'),
      path.join(__dirname, '..', 'src', 'swagger', 'swagger.json'),
    ];
    let swaggerDocument: any = null;
    for (const p of possiblePaths) {
      if (existsSync(p)) {
        swaggerDocument = JSON.parse(readFileSync(p, 'utf8'));
        break;
      }
    }

    if (swaggerDocument) {
      app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument, {
        customSiteTitle: 'Service Booking API Docs',
        customCss: '.swagger-ui .topbar { display: none }',
      }));

      app.get('/api/docs/swagger.json', (req: Request, res: Response) => {
        res.setHeader('Content-Type', 'application/json');
        res.send(swaggerDocument);
      });
    }
  } catch (err: any) {
    console.warn('Swagger documentation could not be loaded:', err.message);
  }

  // Static Assets - Uploaded Profile Images
  app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));

  // Welcome Route
  app.get('/', (req: Request, res: Response) => {
    res.json({
      name: 'Service Booking & Management API',
      version: '1.0.0',
      status: 'active',
      docs: '/api/docs',
      health: '/api/health',
    });
  });

  // Mount API Endpoints
  app.use('/api', apiRouter);

  // 404 Route Handler
  app.use(notFoundHandler);

  // Global Error Handler
  app.use(errorHandler);

  return app;
};
