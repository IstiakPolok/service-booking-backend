import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service.js';
import { ApiResponse } from '../utils/apiResponse.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiError } from '../utils/apiError.js';

export class AuthController {
  /**
   * Register new user
   * POST /api/auth/register
   */
  static register = asyncHandler(async (req: Request, res: Response) => {
    let { name, email, password, phone, avatar } = req.body;

    // If an avatar file was uploaded via multipart/form-data
    if (req.file) {
      const protocol = req.protocol;
      const host = req.get('host');
      avatar = `${protocol}://${host}/uploads/avatars/${req.file.filename}`;
    }

    const { user, token } = await AuthService.register({
      name,
      email,
      password,
      phone,
      avatar,
    });

    return ApiResponse.created(res, 'User registered successfully', {
      user,
      token,
    });
  });

  /**
   * Login user
   * POST /api/auth/login
   */
  static login = asyncHandler(async (req: Request, res: Response) => {
    const { email, password } = req.body;
    const { user, token } = await AuthService.login({ email, password });

    return ApiResponse.success(res, 'Login successful', {
      user,
      token,
    });
  });

  /**
   * Get current authenticated user
   * GET /api/auth/me
   */
  static getMe = asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) {
      throw ApiError.unauthorized();
    }
    return ApiResponse.success(res, 'Authenticated user profile retrieved', req.user);
  });

  /**
   * Change current user's password
   * PUT /api/auth/change-password
   */
  static changePassword = asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) {
      throw ApiError.unauthorized();
    }
    const { currentPassword, newPassword } = req.body;
    await AuthService.changePassword(req.user.id, currentPassword, newPassword);

    return ApiResponse.success(res, 'Password changed successfully');
  });

  /**
   * Logout user (client-side token removal acknowledgment)
   * POST /api/auth/logout
   */
  static logout = asyncHandler(async (req: Request, res: Response) => {
    return ApiResponse.success(res, 'Logged out successfully');
  });
}

