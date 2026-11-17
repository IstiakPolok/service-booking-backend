import { Response } from 'express';

export interface ApiResponsePayload<T = any> {
  success: boolean;
  message: string;
  data?: T;
  meta?: Record<string, any>;
  errors?: any[];
}

export class ApiResponse {
  static success<T>(
    res: Response,
    message: string,
    data?: T,
    meta?: Record<string, any>,
    statusCode = 200
  ): Response {
    const payload: ApiResponsePayload<T> = {
      success: true,
      message,
      data,
    };

    if (meta) {
      payload.meta = meta;
    }

    return res.status(statusCode).json(payload);
  }

  static created<T>(
    res: Response,
    message: string,
    data: T,
    meta?: Record<string, any>
  ): Response {
    return ApiResponse.success(res, message, data, meta, 201);
  }

  static error(
    res: Response,
    message: string,
    statusCode = 500,
    errors?: any[]
  ): Response {
    const payload: ApiResponsePayload = {
      success: false,
      message,
    };

    if (errors && errors.length > 0) {
      payload.errors = errors;
    }

    return res.status(statusCode).json(payload);
  }
}
