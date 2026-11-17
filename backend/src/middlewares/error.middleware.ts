import { Request, Response, NextFunction } from 'express';
import { ApiError } from '../utils/apiError.js';
import { ApiResponse } from '../utils/apiResponse.js';
import { logger } from '../utils/logger.js';
import { ENV } from '../config/env.js';

export const errorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal Server Error';
  let errors = err.errors;

  // Handle Mongoose Bad ObjectId (CastError)
  if (err.name === 'CastError') {
    statusCode = 400;
    message = `Invalid format for resource identifier: ${err.value}`;
  }

  // Handle Mongoose Duplicate Key Error (E11000)
  if (err.code === 11000) {
    statusCode = 409;
    const duplicatedField = Object.keys(err.keyValue || {})[0] || 'field';
    const value = err.keyValue ? err.keyValue[duplicatedField] : '';
    message = `An account with this ${duplicatedField} ('${value}') already exists`;
  }

  // Handle Mongoose Validation Error
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation error occurred';
    errors = Object.values(err.errors).map((val: any) => ({
      field: val.path,
      message: val.message,
    }));
  }

  // Handle JSON Syntax Error in request body
  if (err instanceof SyntaxError && 'body' in err) {
    statusCode = 400;
    message = 'Malformed JSON in request body';
  }

  if (statusCode >= 500) {
    logger.error(`[${req.method}] ${req.originalUrl} - Server Error: ${err.message}`, err.stack);
  } else {
    logger.warn(`[${req.method}] ${req.originalUrl} - ${statusCode}: ${message}`);
  }

  const responsePayload: any = {
    success: false,
    message,
  };

  if (errors && errors.length > 0) {
    responsePayload.errors = errors;
  }

  if (!ENV.IS_PRODUCTION && err.stack && statusCode === 500) {
    responsePayload.stack = err.stack;
  }

  res.status(statusCode).json(responsePayload);
};

export const notFoundHandler = (req: Request, res: Response): void => {
  ApiResponse.error(
    res,
    `Route not found: [${req.method}] ${req.originalUrl}`,
    404
  );
};

